defmodule Api.Resource.Vendors.Vendor_.GET do
  use Api.Resource

  input site
  param vendor, &String.to_atom/1

  condition site && vendor, :not_found

  let conf = vendor |> Api.vendors()
  let restricted? = conf[:restricted] && !conn().private.authenticated
  let display = conf[:display]
  let base = conf[:base]

  hyper do
    action do
      if restricted? do
        error 404
      else
        apply(Site, vendor, [site, base])
        |> Map.put(:name, conf[:name])
        |> Map.put(:display, conf[:display])
      end
    end
  end
end
