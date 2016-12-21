defmodule Mizzen.Resource.Vendors.Malc0de.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.Malc0de.get/1, [site])
    end
  end
end
