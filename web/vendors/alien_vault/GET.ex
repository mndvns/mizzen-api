defmodule Mizzen.Resource.Vendors.AlienVault.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.AlienVault.get/1, [site])
    end
  end
end
