defmodule Mizzen.Vendors.SenderBase do
  require Transform

  @sender_base_url "http://www.senderbase.org/lookup/?search_string="
  @sender_base_geolocation_url "http://www.senderbase.org/api/location_for_ip/?search_string="
  @sender_base_cookie "tos_accepted=1330588800"
  @hackney_opts hackney: [cookie: ["tos_accepted=1330588800"]]

  def name, do: "SenderBase"

  def get(site) do
    case HTTPoison.get(@sender_base_url <> site, %{}, @hackney_opts) do
      {:ok, %{body: body}} ->
        body
        |> Transform.clean(remove_tags: ["script"], remove_attrs: [~r/^on+/, ~r/href/])
        |> Transform.to_html
        |> Transform.map(fn(x) ->
          %{
            "hostname" => x.('//td[@class="info_header"][.="Hostname"]/following-sibling::td/a/text()', "s"),
            "web_reputation" => x.('//td[@class=\"info_header\"][contains(.,\"Web Reputation\")]/following-sibling::td/div[@class=\"leftside\"]/text()', "s"),
            "web_category" => x.('//span[@class="web_category"]/text()', "s"),
            "email_volume last_day" => x.('//tr[child::td[@class="info_header"][contains(.,"Email Volume")]]/td[2]/text()', "s"),
            "email_volume_last_month" => x.('//tr[child::td[@class="info_header"][contains(.,"Email Volume")]]/td[3]/text()', "s")
          }
          end)
        |> Map.merge(%{
            "geolocation" => if Utils.ip?(site) do
                        case HTTPoison.get(@sender_base_geolocation_url <> site) do
                          {:ok, %{body: "Your session has expired or you are not allowed to perform this action. Click <a href=\"/lookup/\">here</a> to continue."}} ->
                            %{error: "no geolocation data"}
                          {:ok, %{body: body}} ->
                            Poison.decode!(body)
                          _ ->
                            %{error: "no geolocation data"}

                        end
            end
          })
      {:error, message} ->
        message
      _ ->
        %{error: "something went wrong"}

    end
  end
end
