defmodule Mizzen.Vendors.WebShrinker do
  @category_url "https://api.webshrinker.com/categories/v2/"
  @screenshot_url "https://api.webshrinker.com/thumbnails/v2/"
  @hackney_opts [hackney: [basic_auth: {"3rDQXaZCEx99Y2gt26v8", "e8HwYz6Oocn00csgn01U"}]]

  def name, do: "WebShrinker"

  def get_category(site) do
    case HTTPoison.get(@category_url <> Base.url_encode64(site), [], @hackney_opts) do
      {:ok, %{body: body}} ->
        body
        |> Poison.decode
        |> elem(1)
      {:error, message} ->
        message
      _ ->
        %{error: "something went wrong"}
    end
  end

  def get_screenshot(site) do
    case HTTPoison.get(@screenshot_url <> Base.url_encode64(site) <> "?size=3xlarge", [], @hackney_opts) do
      {:ok, %{body: body}} ->
        body
      {:error, message} ->
        message
      _ ->
        %{error: "something went wrong"}
    end
  end

  def get_info(site) do
    case HTTPoison.get(@screenshot_url <> Base.url_encode64(site) <> "/info?size=3xlarge&fullpage=true", [], @hackney_opts) do
      {:ok, %{body: body}} ->
        body
        |> Poison.decode
        |> elem(1)
      {:error, message} ->
        message
      _ ->
        %{error: "something went wrong"}
    end
  end

  def get(site) do
    categories = get_category(site)["data"]
    screenshot = get_info(site)["data"]
    list = Enum.concat(categories, screenshot)
    %{
      "categories" => List.first(list),
      "screenshot" => List.last(list)
    }
  end
end
