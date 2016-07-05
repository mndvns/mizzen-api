use Mix.Config

config :api,
  safe_browsing_key: System.get_env("SAFE_BROWSING_KEY"),
  virus_total_key: System.get_env("VIRUS_TOTAL_KEY"),

  store_response: false
