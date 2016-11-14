defmodule Mizzen.Resource.Vendors.RepAuth.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.RepAuth.get/1, [q])
    end
  end
end
