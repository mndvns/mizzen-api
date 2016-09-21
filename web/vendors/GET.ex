defmodule Api.Resource.Vendors.GET do
  use Api.Resource

  input site

  hyper do
    action do
      auth? = conn().private.authenticated
      %{
        "fetch" => link_to("/vendors", nil, %{"site" => site}),
        "collection" => site && ([
          auth? && point_to("/vendors/@vendor", %{"vendor" => "threat_web"}, %{"site" => site}),
          point_to("/vendors/@vendor", %{"vendor" => "virus_total"}, %{"site" => site}),
          point_to("/vendors/@vendor", %{"vendor" => "sender_base"}, %{"site" => site}),
          point_to("/vendors/@vendor", %{"vendor" => "rep_auth"}, %{"site" => site}),
          point_to("/vendors/@vendor", %{"vendor" => "malc0de"}, %{"site" => site}),
        ] |> Enum.filter(&(&1))) || []
      }
    end

    affordance do
      %{
        "input" => %{
          "site" => %{
            "value" => site,
            "required" => true,
          }
        }
      }
    end
  end
end
