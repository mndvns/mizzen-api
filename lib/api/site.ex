defmodule Site do
  require Transform
  require Floki
  require Request
  require IEx

  @safe_browsing_key Application.get_env(:api, :safe_browsing_key)
  @virus_total_key Application.get_env(:api, :virus_total_key)

  def malc0de(site, base) do
    wrap(site, base, fn([get: get, post: _post]) ->
      get.("/database/index.php", %{"search" => site})
      |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on-/, "href", "style"])
      |> Transform.to_html
      |> Transform.map(fn(x) ->
        x.('//tr[@class="class1"]/td//text()', 'sl')
        |> take([
          "Date",
          "File",
          "IP",
          "Country",
          "ASN",
          "ASN Name",
          "MD5"
        ])
      end)
    end)
  end

  def mc_afee(site, base) do
    wrap(site, base, fn([get: get, post: _post]) ->
      get.("/threat-intelligence/domain/default.aspx", %{"domain" => site})
      |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on/, "src", "href", "style"])
      |> Transform.to_html
      |> Transform.map(fn(x) ->
        %{
          "risk" => x.('//img[@id="ctl00_mainContent_imgRisk"]/@title', 's'),
          "category" => String.strip(x.('//strong[contains(., "Web Category")]/../text()', 's')),
          "last_seen" => String.strip(x.('//strong[contains(., "Last Seen")]/../text()', 's')),
        }
      end)
    end)
  end

  def rep_auth(site, base) do
    wrap(site, base, fn([get: get, post: _post]) ->
      get.("/lookup.php", %{"ip" => site})
      |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on-/, "href", "style"])
      |> Transform.to_html
      |> Transform.map(fn(x) ->
        x.('//td[@class="bsnDataRow1"]/following-sibling::td/text()', 'l')
        |> Enum.map(fn(row) -> to_string(row) end)
        |> Enum.zip([
          "reputation_score",
          "reverse_dns",
          "isp_location",
          "isp",
          "clean",
          "viruses",
          "spam",
          "malformed_messages",
          "suspicious",
          "good_recipients",
          "bad_recipients"
        ])
        |> Enum.reduce(%{}, fn({value, key}, acc) ->
          acc = Map.put(acc, key, value)
        end)
      end)
    end)
  end

  def safe_browsing(site, base) do
    wrap(site, base, fn([get: get, post: post]) ->
      body = get.("/lookup", %{
        "client" => "api",
        "apikey" => "ABQIAAAAzO0BeNsWxWi86s2xUZQ1ABTOCj0UZiK_d404jrg3TrlhPfcfBQ",
        "appver" => "1.0",
        "pver" => "3.0",
        "url" => site
      })

      %{
        "is_phishing" => String.contains?(body, "phishing"),
        "is_malware" => String.contains?(body, "malware"),
        "is_unwanted" => String.contains?(body, "unwanted")
      }
    end)
  end

  def sender_base(site, base) do
    wrap(site, base, fn([get: get, post: _post])->
      body = get.("/lookup/", %{"search_string" => site, "tos_accepted" => "Yes, I Agree"})

      {_, _, [string]} = Floki.find(body, "script")
      |> Enum.filter(fn({_tag, attrs, _children}) -> length(attrs) == 0 end)
      |> Enum.filter(fn({_tag, _attrs, [firstLine | _]}) -> String.contains?(firstLine, "authHash") end)
      |> hd

      [_ | [auth]] = Regex.run(~r/authHash\s?=\s?["'](.*)["']/, string)

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
          # TODO
          # "volume_change_last_day" => nil,
          # "volume_change_last_month" => nil,
        }
      end)
      |> Map.merge(%{
        "geolocation" => get.("/api/location_for_ip/", %{"search_string" => site, "auth" => auth}),
        "mail_server" => get.("/api/mail_servers/", %{"search_string" => site, "auth" => auth}),
      })
    end)
  end

  def virus_total(site, base) do
    wrap(site, base, fn([get: _get, post: post]) ->
      post.("/report", {:form, [
        {"resource", site},
        {"apikey", @virus_total_key},
        {"scan", 1}
      ]})
    end, [bypass_store: true])
  end

  defp wrap(site, base, func) do
    wrap(site, base, func, [bypass_store: false])
  end
  defp wrap(site, base, func, [bypass_store: bypass_store]) do
    case ResponseStore.read(site, base) do
      {:ok, res} ->
        res
      _ ->
        {:ok, store} = RequestStore.new()

      get = fn(path, query) ->
        uri = Request.uri(base <> path, query, nil, nil, true)
        RequestStore.add(store, %{"method" => "GET", "uri" => uri})
        Request.get(uri)
      end

      post = fn(path, body) ->
        uri = Request.uri(base <> path, nil, nil, nil, true)
        RequestStore.add(store, %{"method" => "POST", "uri" => uri})
        Request.post(uri, body)
      end

      body = func.([get: get, post: post])

      res = %{
        "requests" => RequestStore.get(store),
        "body" => body
      }

      if !bypass_store do
        ResponseStore.write(site, base, res)
      end

      res
    end
  end

  defp take(list, columns) do
    take(list, columns, [])
  end
  defp take([], _columns, acc) do
    acc
  end
  defp take(list, columns, acc) do
    by = length(columns)
    head = Enum.take(list, by)
    rest = Enum.slice(list, by, 1000)

    buf = head
    |> Enum.zip(columns)
    |> Enum.reduce(%{}, fn({value, key}, acc) ->
      acc = Map.put(acc, key, value)
    end)

    take(rest, columns, acc ++ [buf])
  end
end
