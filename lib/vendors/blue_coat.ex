defmodule Mizzen.Vendors.BlueCoat do
  @blue_coat_url "http://sitereview.bluecoat.com/rest/categorization"
  @blue_coat_header ["Content-Type": "application/x-www-form-urlencoded"]

  def name, do: "BlueCoat"

  def get(site) do
    case HTTPoison.post(@blue_coat_url, {:form, [url: site]}, @blue_coat_header) do
      {:ok, %{body: body}} ->
        categorization = Floki.find(body, "a")
        categories = for e <- categorization, do: elem(e, 2)
        last_reviewed_date = Poison.decode(body) |> elem(1) |> Map.get("ratedate") |> String.split(" <img") |> List.first
        %{
          "categories" => List.flatten(categories),
          "date" => last_reviewed_date
        }
      _ ->
        %{error: "something went wrong"}
    end
  end


end
