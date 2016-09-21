defmodule Api.HTTP.Router do
  use __MODULE__.Helper
  use Plug.ErrorHandler

  plug Plug.XForwardedProto
  plug Plug.Auth
  plug Plug.Parsers,
    parsers: [Plug.Parsers.Wait1, Plug.Parsers.JSON, Plug.Parsers.URLENCODED],
    json_decoder: Poison

  plug :match

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug :dispatch

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, Poison.encode!(%{
      "error" => %{
        "message" => "Something went wrong"
      }
    }))
  end
end
