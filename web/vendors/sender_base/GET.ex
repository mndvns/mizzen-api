defmodule Mizzen.Resource.Vendors.SenderBase.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.SenderBase.get/1, [q])
    end
  end
end
