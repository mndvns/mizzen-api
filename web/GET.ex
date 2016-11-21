defmodule Mizzen.Resource.GET do
  use Mizzen.Resource

  mediatype Hyper do
    action do
      %{
        "vendors" => link_to("/vendors")
      }
    end
  end
end
