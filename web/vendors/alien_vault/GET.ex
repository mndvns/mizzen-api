defmodule Mizzen.Resource.Vendors.AlienVault.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.AlienVault.get/1, [q])
    end
  end
end
