defmodule Api.Resource.Vendors.Vendor_.GET do
  use Api.Resource

  input site
  param vendor, &String.to_atom/1

  condition site && vendor, :not_found

  let conf = vendor |> Api.vendors()
  let display = conf[:display]
  let base = conf[:base]
  let body = apply(Site, vendor, [site, base])

  hyper do
    action do
      body
    end
  end
end

