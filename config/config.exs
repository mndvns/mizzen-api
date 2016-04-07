use Mix.Config

config :api,
  safe_browsing_key: System.get_env("SAFE_BROWSING_KEY")
