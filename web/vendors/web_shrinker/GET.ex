defmodule Mizzen.Resource.Vendors.WebShrinker.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {true, false, false} ->
          Mizzen.Cache.get(&Mizzen.Vendors.WebShrinker.get/1, [site])
        {false, false, true} ->
          Mizzen.Cache.get(&Mizzen.Vendors.WebShrinker.get/1, [site])
        {false, false, false} ->
          Mizzen.Cache.get(&Mizzen.Vendors.WebShrinker.get/1, [site])
        {false, true, false} ->
          %{error: "Requested resource does not accept this type of query"}
      end
    end
  end
end
