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
          let service = apply(Site, unquote(underscore), [site, unquote(base)])

          hyper do
            action do
              %{
                "name" => unquote(display),
                "types" => unquote(types),
                "body" => service
              }
            end
          end

          # def get(url, query \\ nil) do
          #   Request.get(base <> url, query)
          # end
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
        ]}
      else
        %{}
      end)
    end
  end
end