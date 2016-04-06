defmodule Api.Resource.Root do
  use PoeApi.Resource

  let input = Input.get()

  hyper do
    action do
      %{
        "sites" => link_to(Api.Resource.Sites)
      }
    end
  end
end
