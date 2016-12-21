defmodule Mizzen.Resource.Vendors.WebShrinker.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      Mizzen.Cache.get(&Mizzen.Vendors.WebShrinker.get/1, [site])
    end
  end
end
