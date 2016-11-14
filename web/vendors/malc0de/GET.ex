defmodule Mizzen.Resource.Vendors.Malc0de.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.Malc0de.get/1, [q])
    end
  end
end
