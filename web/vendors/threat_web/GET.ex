defmodule Mizzen.Resource.Vendors.ThreatWeb.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {true, false, false} ->
          Mizzen.Cache.get(&Mizzen.Vendors.ThreatWeb.get/1, [site])
        {false, false, true} ->
          Mizzen.Cache.get(&Mizzen.Vendors.ThreatWeb.get/1, [site])
        {false, false, false} ->
          Mizzen.Cache.get(&Mizzen.Vendors.ThreatWeb.get/1, [site])
        {false, true, false} ->
          %{body: %{error: "Requested resource does not accept this type of query"}}
      end
    end
  end
end
