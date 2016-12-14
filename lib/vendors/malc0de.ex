defmodule Mizzen.Vendors.Malc0de do
  require Transform
  @malc0de_url "http://malc0de.com/database/index.php?search="
  @opts [recv_timeout: 16000]

  def name, do: "malc0de"

  def get(query) do
    case HTTPoison.get(@malc0de_url <> query, %{}, @opts) do
      {:ok, %{body: body}} ->
        body
        |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on-/, "href", "style"])
        |> Transform.to_html
        |> IO.inspect()
        |> Transform.map(fn(x) ->
          x.('//tr[@class="class1"]/td//text()', 'sl')
          |> take([
            "Date",
            "File",
            "IP",
            "Country",
            "ASN",
            "ASN Name",
            "MD5"
          ])
        end)
      {:error, message} ->
        message
      _ ->
        %{error: "something went wrong"}
    end
  end

  defp take(list, columns) do
    take(list, columns, [])
  end
  defp take([], _columns, acc) do
    acc
  end
  defp take(list, columns, acc) do
    by = length(columns)
    head = Enum.take(list, by)
    rest = Enum.slice(list, by, 1000)

    buf = head
    |> Enum.zip(columns)
    |> Enum.reduce(%{}, fn({value, key}, acc) ->
      acc = Map.put(acc, key, value)
    end)

    take(rest, columns, acc ++ [buf])
  end
end
