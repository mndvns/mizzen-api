use Mix.Config

config :logger, :console,
  level: :info,
  format: "$message
"

config :mizzen,
  port: (System.get_env("PORT") || "4000") |> String.to_integer,

  auth_id: "8495e3e79bb46bf1c24438ae11b541a35610a0867139bd6fe58cbcf23b4c2078",
  auth_password: "cruisetheseas",
  auth_token_secret: "8ba6daf2be7c74645f17ec3c825fdb5b89915037d7ef468e0359e19c40680c7c",

  safe_browsing_key: "ABQIAAAAzO0BeNsWxWi86s2xUZQ1ABTOCj0UZiK_d404jrg3TrlhPfcfBQ",
  virus_total_url: "https://www.threatweb.com/api",
  virus_total_key: "a71b575b450ac1a14f479e186e2c12880c8ec52762256dff6eb934e035491afa",
  threat_web_key: "d29b598b-81fd-4628-8ad4-086678ae12cd"
