defmodule Mizzen.Resource.Vendors.ThreatWeb.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.ThreatWeb.get/1, [site])
    end
  end
end
