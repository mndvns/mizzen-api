defmodule Utils do
  def ip?(string) do
    Regex.match?(~r/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/, string)
  end

  def file_hash?(string) do
    md5?(string) or sha1?(string) or sha256?(string)
  end

  def domain?(uri) do
    Regex.match?(~r/^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$/, uri)
  end

  def format_date(unix) do
    unix |> DateTime.from_unix!() |> DateTime.to_iso8601()
  end

  def parse_date(date) do
    [head, tail] = date |> String.split("T")
    head = String.split(head, "-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    tail = String.replace(tail, "Z", "") |> String.split(":") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    seen = {head, tail} |> Calendar.DateTime.from_erl!("GMT") |> DateTime.to_unix()
  end

  defp md5?(string) do
    Regex.match?(~r/^[0-9a-fA-F]{32}$/, string)
  end

  defp sha1?(string) do
    Regex.match?(~r/^[0-9a-fA-F]{40}$/, string)
  end

  defp sha256?(string) do
    Regex.match?(~r/^[0-9a-fA-F]{64}$/, string)
  end

  def parse_query(query) do
    {ip?(query), file_hash?(query), domain?(query)}
  end

end
