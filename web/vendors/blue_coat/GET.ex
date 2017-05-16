defmodule Mizzen.Resource.Vendors.BlueCoat.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {false, false, _} ->
          Mizzen.Cache.get(&Mizzen.Vendors.BlueCoat.get/1, [site])
        _ ->
          %{error: "Requested resource does not accept this type of query"}
      end
    end
  end
end
