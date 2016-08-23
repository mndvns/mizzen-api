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
          link_to(Api.Sites.ThreatWeb, nil, input),
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
