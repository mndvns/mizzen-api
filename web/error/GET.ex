defmodule Api.Resource.Error.GET do
  use Api.Resource

  hyper do
    action do
      status 404
      %{
        "error" => %{
          "message" => "Not found"
        }
      }
    end
  end
end
