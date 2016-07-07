use Mix.Config

config :api,
  safe_browsing_key: System.get_env("SAFE_BROWSING_KEY"),
  virus_total_key: System.get_env("VIRUS_TOTAL_KEY"),

  store_response: false,

  vendors: %{
    malc0de: %{
      name: "Malc0de",
      display: "malc0de",
      types: ["ip"],
      base: "http://malc0de.com"
    },
    # TODO
    # mc_afee: %{
    #   name: "McAfee",
    #   display: "McAfee",
    #   types: ["hostname"],
    #   base: "http://www.mcafee.com"
    # },
    rep_auth: %{
      name: "RepAuth",
      display: "Reputation Authority",
      types: ["ip", "domain"],
      base: "http://www.reputationauthority.org"
    },
    # TODO
    # safe_browsing: %{
    #   name: "SafeBrowsing",
    #   display: "Safe Browsing",
    #   types: ["hostname"],
    #   base: "https://sb-ssl.google.com/safebrowsing/api"
    # },
    sender_base: %{
      name: "SenderBase",
      display: "SenderBase",
      types: ["ip", "domain"],
      base: "http://www.senderbase.org"
    },
    virus_total: %{
      name: "VirusTotal",
      display: "Virus Total",
      types: ["ip", "domain", "url"],
      base: "https://www.virustotal.com/vtapi/v2"
    },
  }


