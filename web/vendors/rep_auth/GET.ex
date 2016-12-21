defmodule Mizzen.Resource.Vendors.RepAuth.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.RepAuth.get/1, [site])
    end
  end
end
