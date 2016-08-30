defmodule Api.Resource.GET do
  use Api.Resource

  hyper do
    action do
      %{
        "vendors" => link_to("/vendors")
      }
    end
  end
end
