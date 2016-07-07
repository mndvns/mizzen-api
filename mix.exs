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
        :con_cache,
        :logger,
        :poe_api,
        :simple_env,
        :virus_total],
     mod: { Api, [] },]
  end

  defp deps do
    [
      {:con_cache, "~> 0.11.1"},
      {:floki, "~> 0.8.0" },
      {:html_entities, "~> 0.3" },
      {:httpoison, "~> 0.8.0" },
      {:poe_api, github: "poegroup/poe-api" },
      {:simple_env, github: "camshaft/simple_env" },
      {:sweet_xml, "~> 0.6.1" },
      {:virus_total, "~> 0.0.1"},
    ]
  end
end
