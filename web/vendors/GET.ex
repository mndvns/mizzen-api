defmodule Mizzen.Resource.Vendors.GET do
  use Mizzen.Resource

  input q, &(&1 && [q: &1])

  let q = q || []
  let query = Input.get()["q"]
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
          link_to("/vendors/virus_total", nil, Keyword.merge(q, meta)),
          link_to("/vendors/malc0de", nil, q),
          link_to("/vendors/rep_auth", nil, q),
          link_to("/vendors/sender_base", nil, q),
          link_to("/vendors/threat_web", nil, q),
          link_to("/vendors/blue_coat", nil, q),
          link_to("/vendors/web_shrinker", nil, q),
          link_to("/vendors/alien_vault", nil, q)
        ]
      }
      |> Map.put("search", link_to("/vendors", nil, q || []))
    end
    affordance do
      %{
        "input" => %{
          "q" => %{
             "type" => "text",
             "required" => true,
             "value" => query,
           }
        }
      }
    end
  end
end
