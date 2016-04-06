defmodule Api.Dispatch do
  use PoeApi.Dispatch

  service Site,                 Site
  service Site.malc0de/2,       Site.malc0de
  service Site.mc_afee/2,       Site.mc_afee
  service Site.rep_auth/2,      Site.rep_auth
  service Site.safe_browsing/2, Site.safe_browsing
  service Site.sender_base/2,   Site.sender_base
end
