defmodule Mizzen.Mixfile do
  use Mix.Project

  def project do
    [app: :mizzen,
     version: "0.1.1",
     elixir: "~> 1.3",
     deps: deps,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_paths: ["web"],
     elixirc_paths: ["lib", "web"]
   ]
  end

  def application do
    [mod: {Mizzen, []},
     applications: [
       :cachex,
       :calendar,
       :cowboy,
       :httpoison,
       :logger,
     ] ++ (Mix.env == :dev && dev_applications || [])]
  end

  defp dev_applications do
    [:rl,]
  end

  defp deps do
    [{:cachex, "~> 2.0.0"},
     {:calendar, "~> 0.16.0"},
     {:concerto, "~> 0.1.2"},
     {:concerto_plug, "~> 0.1.0"},
     {:cowboy, "~> 1.0.0"},
     {:floki, "~> 0.11.0"},
     {:fugue, "~> 0.1.2"},
     {:html_entities, "~> 0.3.0"},
     {:httpoison, "~> 0.10.0"},
     {:mazurka, "~> 1.0.0"},
     {:mazurka_plug, "~> 0.1.0"},
     {:plug, "~> 1.2.0"},
     {:plug_wait1, "~> 0.2.1"},
     {:plug_x_forwarded_proto, "~> 0.1.0"},
     {:poison, "2.2.0"},
     {:rl, github: "camshaft/rl", only: [:dev, :test]},
     {:simple_secrets, "1.0.0"},
     {:sweet_xml, "~> 0.6.2"}]
  end
end
