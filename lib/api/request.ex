defmodule Request do
  require HTTPoison
  require Logger

  def post(url, data) do
    post(url, nil, data)
  end
  def post(url, query, data) do
    %HTTPoison.Response{body: body} = HTTPoison.post!(uri(url, query, "POST"), data)
    body |> Poison.decode!
  end

  def get(url, query \\ nil) do
    get(url, query, [json: true])
  end
  def get(url, query, [json: json]) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(uri(url, query, "GET"))

    if json do
      case body |> Poison.decode do
        {:ok, json} ->
          json
        _ ->
          body
      end
    else
      body
    end
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

  def uri(url, query \\ nil, method \\ "GET", data \\ nil, silent \\ false) do
    uri = url <> query_encode(query)
    if !silent do
      Logger.info("#{method} #{uri}")
      if not is_nil(data) do
        IO.inspect data
      end
    end
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
