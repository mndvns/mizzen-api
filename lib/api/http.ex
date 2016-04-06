defmodule Api.HTTP do
  use PoeApi.HTTP

  get  "/",                    Api.Resource.Root
  get  "/sites",               Api.Resource.Sites
  post "/sites",               Api.Resource.Sites.Fetch

  get  "/sites/malc0de",       Api.Sites.Malc0de
  get  "/sites/mc_afee",       Api.Sites.McAfee
  get  "/sites/rep_auth",      Api.Sites.RepAuth
  get  "/sites/safe_browsing", Api.Sites.SafeBrowsing
  get  "/sites/sender_base",   Api.Sites.SenderBase
end
