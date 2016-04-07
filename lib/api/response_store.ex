defmodule ResponseStore do
  require IEx

  def read(site, base) do
    File.open(path(site, base), [:read], fn(file) ->
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

  def write(site, base, data) do
    File.open(path(site, base), [:write], fn(file) ->
      IO.binwrite(file, Poison.encode_to_iodata!(data))
    end)
  end

  defp path(site, base) do
    delimiter = "---"
    clean_url = String.replace(site <> delimiter <> base, ~r/[^a-zA-Z0-9_\-\.\s]/, "")
    "data/" <> date() <> delimiter <> clean_url
  end

  defp date do
    {{year, month, day}, _} = :calendar.universal_time
    date = Enum.join([year, month, day], "-")
  end
end
