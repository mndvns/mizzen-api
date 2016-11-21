defmodule Mizzen.Vendors.RepAuth do
  require Transform
  @rep_auth_url "http://www.reputationauthority.org/"
  @ip_lookup "lookup.php"
  @domain_lookup "domain_lookup.php"

  def name, do: "RepAuth"

  def get(query) do
    path = if Utils.ip? query do
      @ip_lookup
    else
      @domain_lookup
    end

    case HTTPoison.get(@rep_auth_url <> path, %{}, params: %{"ip" => query}) do
      {:ok, %{body: body}} ->
        body
        |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on-/, "href", "style"])
        |> Transform.to_html
        |> Transform.map(fn(x) ->
          x.('//td[@class="bsnDataRow1"]/following-sibling::td/text()', 'l')
          |> Enum.map(fn(row) -> to_string(row) end)
          |> Enum.zip([
            "reputation_score",
            "reverse_dns",
            "isp_location",
            "isp",
            "clean",
            "viruses",
            "spam",
            "malformed_messages",
            "suspicious",
            "good_recipients",
            "bad_recipients"
          ])
          |> Enum.reduce(%{}, fn({value, key}, acc) ->
            acc = Map.put(acc, key, value)
          end)
        end)
      _ ->
        %{error: "something went wrong"}
    end
  end
end
