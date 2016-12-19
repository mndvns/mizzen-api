defmodule Mizzen.Resource.Vendors.VirusTotal.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.VirusTotal.scan/1, [q])
    end
  end
end
