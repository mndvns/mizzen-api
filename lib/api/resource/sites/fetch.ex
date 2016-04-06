defmodule Api.Resource.Sites.Fetch do
  use PoeApi.Resource

  hyper do
    action do
      transition_to(Api.Resource.Sites, nil, Input.get())
    end

    affordance do
      %{
        "input" => %{
          "site" => %{
            "value" => Input.get("site"),
            "required" => true
          }
        }
      }
    end
  end
end
