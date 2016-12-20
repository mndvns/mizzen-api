defmodule Mizzen.Router do
  use Plug.Builder
  use Concerto, [root: "#{System.cwd!}/web",
                 ext: ".ex",
                 module_prefix: Mizzen.Resource]
  use Concerto.Plug.Mazurka

  plug Plug.Auth

  plug :match

  plug PlugXForwardedProto

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end
  plug :dispatch
end
