defmodule Mizzen.Resource.Error.GET do
  use Mizzen.Resource

  mediatype Hyper do
    action do
      %{
        "error" => %{
          "message" => "Resource not found"
        }
      }
    end
  end
end
