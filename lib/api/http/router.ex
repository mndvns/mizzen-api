defmodule Api.HTTP.Router do
  use __MODULE__.Helper

  plug Plug.Parsers,
    parsers: [Plug.Parsers.Wait1, Plug.Parsers.JSON, Plug.Parsers.URLENCODED],
    json_decoder: Poison

  plug :match

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug :dispatch
end
