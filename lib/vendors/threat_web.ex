defmodule Mizzen.Vendors.ThreatWeb do
  @threat_web_key Application.get_env(:mizzen, :threat_web_key)
  @threat_web_url "https://www.threatweb.com/api?"

  @hackney_opts [ssl_options: [server_name_indication: :disable]]
  @req_headers %{"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36"}

  def name, do: "ThreatWeb"

  def get(site) do
    case HTTPoison.get(@threat_web_url <> URI.encode_query(%{"apikey" => @threat_web_key, "q" => site}), @req_headers, @hackney_opts) do
      {:ok, %{body: body}} ->
        body
        |> String.split("\n")
        |> Enum.map(&Poison.decode!/1)
        |> format_tw_response()
        |> Enum.to_list()
        |> List.wrap()
      _ ->
        %{error: "something went wrong"}
    end
  end

  defp format_tw_response(input) do
    props = %{
      confidence: [],
      seen: [],
      sources: %{},
    }

    groups = Enum.reduce(input, %{}, fn(item, groups) ->
      alternative_id = item["alternativeid"]
      description = item["description"]
      assessment = item["assessment"] |> String.to_atom()
      group = %{confidence: confidence_list, seen: seen_list, sources: sources} = groups[assessment] || props

      sources = cond do
        alternative_id && description ->
          source = sources[alternative_id] || []
          Map.put(sources, alternative_id, [description | source] |> Enum.uniq())

        description ->
          source = sources["None"] || []
          Map.put(sources, "None", [description | source] |> Enum.uniq())

        true ->
          sources
      end
      {confidence, _} = item["confidence"] |> Float.parse()
      seen = item["reporttime"] |> Utils.parse_date()
      group = group
      |> Map.put(:confidence, [confidence | confidence_list])
      |> Map.put(:seen, [seen | seen_list])
      |> Map.put(:sources, sources)
      groups = Map.put(groups, assessment, group)
    end)

    Enum.map(groups, fn({assessment, group = %{seen: seen_list, confidence: confidence_list, sources: sources}}) ->
      %{
        assessment: assessment,
        first_seen: seen_list |> Enum.sort() |> hd() |> Utils.format_date(),
        last_seen: seen_list |> Enum.sort() |> Enum.reverse() |> hd() |> Utils.format_date(),
        highest_confidence: confidence_list |> Enum.sort() |> Enum.reverse() |> hd(),
        average_confidence: ((confidence_list |> Enum.reduce(0, &(&1 + &2))) / length(confidence_list)),
        sources: sources |> Enum.map(fn({k, v}) -> {k, Enum.join(v, ", ")} end) |> Enum.into(%{}),
        record_count: map_size(group),
      }
    end)
  end
end
