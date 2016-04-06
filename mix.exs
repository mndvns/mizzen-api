defmodule Api.Mixfile do
  use Mix.Project

  def project do
    [app: :api,
     version: "0.0.1",
     description: "API for commonly used web security tools",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [
        :logger,
        :poe_api,
        :simple_env],
     mod: { Api, [] },]
  end

  defp deps do
    [{ :poe_api, github: "poegroup/poe-api" },
     { :html_entities, "~> 0.3" },
     { :httpoison, "~> 0.8.0" },
     { :simple_env, github: "camshaft/simple_env" },
     { :sweet_xml, "~> 0.6.1" },
     { :floki, "~> 0.8.0" }]
  end
end
