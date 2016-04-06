defmodule Request do
  require HTTPoison
  require Logger

  def get(url, query \\ nil) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(uri(url, query))
    body
  end

  def get_json(url, query \\ nil) do
    body = get(url, query)
    case body |> Poison.decode do
      {:ok, json} ->
        json
      _ ->
        body
    end
  end

  def uri(url, query \\ nil) do
    uri = url <> query_encode(query)
    Logger.info("GET #{uri}")
    uri
  end

  defp query_encode(query) when is_nil(query) do
    ""
  end
  defp query_encode(query) when length(query) == 0 do
    ""
  end
  defp query_encode(query) do
    "?" <> (query
    |> Map.to_list
    |> Enum.map(fn({key, value}) ->
      key <> "=" <> URI.encode(value)
    end)
    |> Enum.join("&"))
  end
end
