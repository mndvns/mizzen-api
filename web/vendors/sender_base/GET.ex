defmodule Mizzen.Resource.Vendors.SenderBase.GET do
  use Mizzen.Resource

  input site

  mediatype Hyper do
    action do
      case Utils.parse_query(site) do
        {true, _, _} ->
          Mizzen.Cache.get(&Mizzen.Vendors.SenderBase.get/1, [site])
        {_, _, true} ->
          Mizzen.Cache.get(&Mizzen.Vendors.SenderBase.get/1, [site])
        _ ->
          %{error: "Requested resource does not accept this type of query"}
      end
    end
  end
end
