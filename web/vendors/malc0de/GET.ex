defmodule Mizzen.Resource.Vendors.Malc0de.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {true, _, _} ->
          Mizzen.Cache.get(&Mizzen.Vendors.Malc0de.get/1, [site])
        _ ->
          %{body: %{error: "Requested resource does not accept this type of query"}}
      end
    end
  end
end
