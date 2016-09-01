defmodule Api.HTTP.Router do
  use __MODULE__.Helper

  @bauth_username Application.get_env(:api, :bauth_username)
  @bauth_password Application.get_env(:api, :bauth_password)
  @bauth_realm Application.get_env(:api, :bauth_realm)

  plug Plug.Parsers,
    parsers: [Plug.Parsers.Wait1, Plug.Parsers.JSON, Plug.Parsers.URLENCODED],
    json_decoder: Poison

  plug :match

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug BasicAuth, realm: @bauth_realm, username: @bauth_username, password: @bauth_password

  plug :dispatch
end
