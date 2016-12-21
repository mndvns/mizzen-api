defmodule Mizzen.Resource.Vendors.VirusTotal.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.VirusTotal.scan/1, [site])
    end
  end
end
