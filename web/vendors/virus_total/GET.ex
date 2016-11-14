defmodule Mizzen.Resource.Vendors.VirusTotal.GET do
  use Mizzen.Resource

  input q
  input ip, &(&1 == "true")
  input domain, &(&1 == "true")
  input file_hash, &(&1 == "true")

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.VirusTotal.scan/2, [q, {ip, file_hash, domain}])
    end
  end
end
