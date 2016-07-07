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
end
