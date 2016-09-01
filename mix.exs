defmodule Api.Mixfile do
  use Mix.Project

  def project do
    [app: :api,
     version: "0.0.1",
     description: "API for commonly used web security tools",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: load(:deps),
     test_paths: ["web"],
     elixirc_paths: ["lib", "web"],]
  end

  def application do
    [applications: load(:applications),
     mod: { Api, [] },]
  end

  def applications do
    [:con_cache,
     :cowboy,
     :httpoison,
     :logger,]
  end

  def dev_applications do
    [:rl,]
  end

  def deps do
    [{:con_cache, "~> 0.11.1"},
     {:concerto, "~> 0.1.2"},
     {:floki, "~> 0.8.0" },
     {:fugue, "~> 0.1.2"},
     {:html_entities, "~> 0.3" },
     {:httpoison, "~> 0.9.0"},
     {:mazurka, "~> 1.0.3"},
     {:plug, "~> 0.13.0", override: true},
     {:plug_wait1, "~> 0.1.2"},
     {:poison, "2.2.0", override: true},
     {:sweet_xml, "~> 0.6.1" },
     {:basic_auth, "~> 1.0.0"}]
  end

  def dev_deps do
    [{:rl, github: "camshaft/rl", only: :dev},]
  end


  defp load(fun) do
    apply(__MODULE__, fun, []) ++ (if Mix.env == :dev do
      dev_fun = :"dev_#{to_string(fun)}"
      apply(__MODULE__, dev_fun, [])
    end || [])
  end
end
