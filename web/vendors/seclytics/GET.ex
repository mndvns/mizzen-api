defmodule Mizzen.Resource.Vendors.Seclytics.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.Seclytics.get/1, [site])
    end
  end
end
