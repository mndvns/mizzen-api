defmodule Api.Sites do
end

defmodule Api.Sites.Mount do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      site name: "Malc0de", display: "malc0de", types: ["ip", "hostname", "md5"],
      base: "http://malc0de.com"

      site name: "McAfee", display: "McAfee", types: ["hostname"],
      base: "http://www.mcafee.com"

      site name: "RepAuth", display: "Reputation Authority", types: ["ip"],
      base: "http://www.reputationauthority.org"

      site name: "SafeBrowsing", display: "Safe Browsing", types: ["hostname"],
      base: "https://sb-ssl.google.com/safebrowsing/api"

      site name: "SenderBase", display: "SenderBase", types: ["ip"],
      base: "http://www.senderbase.org"

      site name: "VirusTotal", display: "Virus Total", types: ["ip"],
      base: "https://www.virustotal.com/vtapi/v2"
    end
  end

  defmacro site([name: name, display: display, types: types, base: base]) do
    mod = Module.concat([Api, Sites, name])
    underscore = String.to_atom(Mix.Utils.underscore(name))

    quote do
      base = unquote(base)
      display = unquote(display)
      types = unquote(types)
      underscore = unquote(underscore)

      contents =
        quote do
          require Request
          use PoeApi.Resource

          let site = Input.get("site")
          let res = apply(Site, unquote(underscore), [site, unquote(base)])
          let meta do
            %{
              "name" => unquote(display),
              "types" => unquote(types),
            }
          end

          hyper do
            action do
              %{
                "meta" => meta |> ^Map.merge(%{
                  "requests" => res["requests"],
                  "is_ip" => res["is_ip"],
                }),
                "body" => res["body"]
              }
            end

            affordance do
              meta
            end
          end
        end

      Module.create(unquote(mod), contents, Macro.Env.location(__ENV__))
    end
  end
end

defmodule Api.Resource.Sites do
  use PoeApi.Resource
  use Api.Sites.Mount

  let input = Input.get()
  let site = Input.get("site")

  hyper do
    action do
      %{
        "fetch" => link_to(Api.Resource.Sites.Fetch, nil, Input.get()),
      }
      |> ^Map.merge(
      if site do
        %{"collection" => [
          link_to(Api.Sites.Malc0de, nil, input),
          link_to(Api.Sites.McAfee, nil, input),
          link_to(Api.Sites.RepAuth, nil, input),
          link_to(Api.Sites.SafeBrowsing, nil, input),
          link_to(Api.Sites.SenderBase, nil, input),
          link_to(Api.Sites.VirusTotal, nil, input),
        ]}
      else
        %{}
      end)
    end
  end
end
