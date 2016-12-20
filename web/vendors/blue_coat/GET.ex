defmodule Mizzen.Resource.Vendors.BlueCoat.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.BlueCoat.get/1, [q])
    end
  end
end
