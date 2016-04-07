defmodule Site do
  require Transform
  require Floki
  require Request
  require IEx

  @safe_browsing_key Application.get_env(:api, :safe_browsing_key)
  # @virus_total_key Application.get_env(:api, :virus_total_key)
  @virus_total_key "5e4581b65bb6d42055f3e1924813b498a5f94366ad1267eaf23c7f10eaa07471"

  def malc0de(site, base) do
    wrap("malc0de", site, base, fn(conf) ->
      conf.get.("/database/index.php", %{"search" => site})
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
    wrap("mc_afee", site, base, fn(conf) ->
      conf.get.("/threat-intelligence/domain/default.aspx", %{"domain" => site})
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
    wrap("rep_auth", site, base, fn(conf) ->
      conf.get.("/lookup.php", %{"ip" => site})
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
    wrap("safe_browsing", site, base, fn(conf) ->
      body = conf.get.("/lookup", %{
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
    wrap("sender_base", site, base, fn(conf)->
      body = conf.get.("/lookup/", %{"search_string" => site, "tos_accepted" => "Yes, I Agree"})

      # TODO fix this crap
      auth = if conf.is_ip do
        [{_, _, [string]} | _] = Floki.find(body, "script")
        |> Enum.filter(fn({_tag, attrs, _children}) -> length(attrs) == 0 end)
        |> Enum.filter(fn({_tag, _attrs, [firstLine | _]}) -> String.contains?(firstLine, "authHash") end)

        [_ | [auth]] = Regex.run(~r/authHash\s?=\s?["'](.*)["']/, string)
        auth
      else
        ""
      end

      site_host = if conf.is_ip do
        site
      else
        URI.parse(site) |> Map.get(:host)
      end

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
        "geolocation" => if conf.is_ip do
          conf.get.("/api/location_for_ip/", %{"search_string" => site, "auth" => auth})
        else
          nil
        end,
        "mail_server" => if conf.is_ip do
          conf.get.("/api/mail_servers/", %{"search_string" => site_host, "auth" => auth})
        else
          nil
        end
      })
    end)
  end

  def virus_total(site, base) do
    wrap("virus_total", site, base, fn(conf) ->
      %{
        "url" => conf.post.("/url/report", {:form, [
          {"apikey", @virus_total_key},
          {"resource", site},
          {"scan", 1}
        ]})
      }
      |> Map.merge(
        if conf.is_ip do
          %{
            "ip" => conf.get.("/ip-address/report", %{
              "apikey" => @virus_total_key,
              "ip" => site,
            })
          }
        else
          %{}
        end)
    end, [use_store: fn(res) ->
      if res["is_ip"] do
        res["body"]["ip"]["verbose_msg"] == "IP address in dataset" &&
        res["body"]["url"]["verbose_msg"] == "Scan finished, scan information embedded in this object"
      else
        res["body"]["url"]["verbose_msg"] == "Scan finished, scan information embedded in this object"
      end
    end])
  end

  defp wrap(name, site, base, func) do
    wrap(name, site, base, func, [use_store: true])
  end
  defp wrap(name, site, base, func, [use_store: use_store]) do
    case ResponseStore.read(site, name) do
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

        is_ip = Regex.match?(~r/^[\d*]\.[\d*]\.[\d*]\.[\d*]$/, site)

        body = func.(%{get: get, post: post, is_ip: is_ip})

        res = %{
          "body" => body,
          "is_ip" => is_ip,
          "requests" => RequestStore.get(store),
        }

        cond do
          is_boolean(use_store) && use_store ->
            ResponseStore.write(site, name, res)
          is_function(use_store) && use_store.(res) ->
            ResponseStore.write(site, name, res)
          true ->
            nil
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
