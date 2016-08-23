use Mix.Config

config :api,
  safe_browsing_key: "ABQIAAAAzO0BeNsWxWi86s2xUZQ1ABTOCj0UZiK_d404jrg3TrlhPfcfBQ",
  virus_total_key: "5e4581b65bb6d42055f3e1924813b498a5f94366ad1267eaf23c7f10eaa07471",
  threat_web_key: "d29b598b-81fd-4628-8ad4-086678ae12cd",

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

    threat_web: %{
      name: "ThreatWeb",
      display: "Threat Web",
      types: ["ip", "domain", "url"],
      base: "https://www.threatweb.com/api"
    }
  }
