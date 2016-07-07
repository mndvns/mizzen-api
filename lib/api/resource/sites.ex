defmodule Api.Sites do
end

defmodule Api.Sites.Mount do
  defmacro __using__(_) do
    vendors = Api.vendors |> Map.values
    [quote do
      import unquote(__MODULE__)
    end] ++ for vendor <- vendors do
      quote do
        site unquote(vendor)
      end
    end
  end

  defmacro site(%{base: base, display: display, name: name, types: types}) do
    mod = Module.concat([Api, Sites, name])
    underscore = String.to_atom(Mix.Utils.underscore(name))

    quote do
      base = unquote(base)
      display = unquote(display)
      underscore = unquote(underscore)

      contents =
        quote do
          use PoeApi.Resource

          let site = Input.get("site")
          let res = apply(Site, unquote(underscore), [site, unquote(base)])
          let meta do
            %{
              "name" => unquote(display),
            }
          end

          hyper do
            action do
              %{
                "meta" => meta |> ^Map.merge(%{
                  "is_ip" => res["is_ip"],
                  "is_domain" => res["is_domain"]
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
          link_to(Api.Sites.VirusTotal, nil, input),
          link_to(Api.Sites.SenderBase, nil, input),
          # link_to(Api.Sites.McAfee, nil, input),
          # link_to(Api.Sites.SafeBrowsing, nil, input),
          link_to(Api.Sites.RepAuth, nil, input),
          link_to(Api.Sites.Malc0de, nil, input),
        ]}
      else
        %{}
      end)
    end
  end
end
