defmodule Mizzen.Resource.Vendors.ThreatWeb.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.ThreatWeb.get/1, [q])
    end
  end
end
