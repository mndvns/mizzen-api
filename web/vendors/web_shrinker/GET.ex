defmodule Mizzen.Resource.Vendors.WebShrinker.GET do
  use Mizzen.Resource

  input q

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.WebShrinker.get/1, [q])
    end
  end
end
