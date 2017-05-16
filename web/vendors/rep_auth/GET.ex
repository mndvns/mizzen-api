defmodule Mizzen.Resource.Vendors.RepAuth.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {true, _, _} ->
          Mizzen.Cache.get(&Mizzen.Vendors.RepAuth.get/1, [site])
        {_, _, true} ->
          Mizzen.Cache.get(&Mizzen.Vendors.RepAuth.get/1, [site])
        _ ->
          %{body: %{error: "Requested resource does not accept this type of query"},
           name: "Reputation Authority"}
      end
    end
  end
end
