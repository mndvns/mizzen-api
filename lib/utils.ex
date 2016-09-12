defmodule Utils do
  def ip?(string) do
    Regex.match?(~r/^[\d*]\.[\d*]\.[\d*]\.[\d*]$/, string)
  end

  def domain?(uri) do
    if ip?(uri) do
      false
    else
      %{authority: authority, path: path} = parsed = uri |> URI.parse
      parts = URI.path_to_segments(path || authority)

      (parts |> tl |> length) == 0
    end
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

end
