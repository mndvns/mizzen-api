defmodule ResponseStore do
  require IEx

  def read(site, name) do
    File.open(path(site, name), [:read], fn(file) ->
      contents = IO.binread(file, :all)
      case contents do
        contents when is_binary(contents) ->
          case Poison.decode(contents) do
            {:ok, parsed} ->
              parsed
            _ ->
              contents
          end
        {:error, _reason} ->
          {:none}
      end
    end)
  end

  def write(site, name, data) do
    File.open(path(site, name), [:write], fn(file) ->
      IO.binwrite(file, Poison.encode_to_iodata!(data))
    end)
  end

  defp path(site, name) do
    delimiter = "_"
    clean_url = String.replace(site, ~r/[^a-zA-Z0-9_\-\.\s]/, "")
    "data/" <> Enum.join([date, clean_url, name], delimiter)
  end

  defp date do
    {{year, month, day}, _} = :calendar.universal_time
    date = Enum.join([year, month, day], "-")
  end
end
