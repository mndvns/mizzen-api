defmodule Request do
  require HTTPoison
  require Logger

  def post(url, data) do
    post(url, nil, data)
  end
  def post(url, query, data) do
    %HTTPoison.Response{body: body} = HTTPoison.post!(url, data, timeout: 12000, recv_timeout: 12000)
    body |> Poison.decode!
  end

  def get(url, query \\ %{}, cookies \\ []) do
    cookie = Enum.reduce(cookies, "", fn({k, v}, acc) ->
      acc <> k <> "=" <> to_string(v) <> "; "
    end)
    |> String.trim

    opts = [
      timeout: 12000,
      recv_timeout: 12000
    ]

    opts = if String.length(cookie) > 0 do
      opts ++ [hackney: [cookie: [cookie]]]
    else
      opts
    end

    %HTTPoison.Response{body: body} = HTTPoison.get!(uri(url, query), %{}, opts)

    case body |> Poison.decode do
      {:ok, json} ->
        json
      _ ->
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
    |> Enum.filter(fn({key, value}) ->
        is_binary(value) && String.length(value) > 0
      end)
    |> Enum.map(fn({key, value}) ->
        key <> "=" <> URI.encode(value)
      end)
    |> Enum.join("&"))
  end
end
