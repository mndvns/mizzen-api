defmodule Mizzen.Resource.Vendors.GET do
  use Mizzen.Resource

  input site, &(&1 && [site: &1])

  let site = site || []
  let query = Input.get()["site"]
  let ip? = query && Utils.ip?(query)
  let file_hash? = query && Utils.file_hash?(query)
  let domain? = query && Utils.domain?(query)
  let meta = [ip: ip?, file_hash: file_hash?, domain: domain?]

  mediatype Hyper do
    action do
      %{
        "meta" => %{
          "is_ip" => ip?,
          "is_file_hash" => file_hash?,
          "is_domain" => domain?,
        },
        "collection" => [
          link_to("/vendors/virus_total", nil, site),
          link_to("/vendors/malc0de", nil, site),
          link_to("/vendors/rep_auth", nil, site),
          link_to("/vendors/sender_base", nil, site),
          link_to("/vendors/threat_web", nil, site),
          link_to("/vendors/blue_coat", nil, site),
          link_to("/vendors/web_shrinker", nil, site),
          link_to("/vendors/alien_vault", nil, site)
        ]
      }
      |> Map.put("search", link_to("/vendors", nil, site || []))
    end
    affordance do
      %{
        "input" => %{
          "site" => %{
             "type" => "text",
             "required" => true,
             "value" => query,
           }
        }
      }
    end
  end
end
