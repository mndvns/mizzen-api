defmodule Site.Helper do
  # TODO simplify these dumb macros

  defmacro defsite({name, _, [{a1, _, _}, {a2, _, _}]}, [do: block]) do
    fun = """
      fn(#{a1}, #{a2}) ->
        #{Macro.to_string(block)}
      end
    """
    |> Code.string_to_quoted
    |> elem(1)

    quote do
      def unquote(name)(site, base) do
        ConCache.get_or_store(unquote(name), site, fn ->
          wrap(site, base, fn(conf) ->
            (unquote(fun)).(site, conf)
          end)
        end)
      end
    end
  end

  defmacro defsite({name, _, [{a1, _, _}]}, [do: block]) do
    fun = """
      fn(#{a1}) ->
        #{Macro.to_string(block)}
      end
    """
    |> Code.string_to_quoted
    |> elem(1)

    quote do
      def unquote(name)(site, base \\ nil) do
        ConCache.get_or_store(unquote(name), site, fn ->
          (unquote(fun)).(site)
        end)
      end
    end
  end
end

defmodule Site do
  require Transform
  require Floki
  require Request

  @threat_web_key Application.get_env(:api, :threat_web_key)
  @safe_browsing_key Application.get_env(:api, :safe_browsing_key)

  import Site.Helper

  defsite virus_total(site) do
    Api.VirusTotal.scan(site)
  end

  defsite threat_web(site, conf) do
    conf.get.("", %{"q" => site, "apikey" => @threat_web_key}, [])
    |> String.split("\n")
    |> Stream.map(&Poison.decode!/1)
    |> format_tw_response()
    |> Enum.to_list()
    |> List.wrap()
  end

  defp format_tw_response(input) do

    props = %{
      confidence: [],
      seen: [],
      sources: %{},
    }
    groups = Enum.reduce(input, %{}, fn(item, groups) ->
      alternative_id = item["alternativeid"]
      description = item["description"]
      assessment = item["assessment"] |> String.to_atom()
      group = %{confidence: confidence_list, seen: seen_list, sources: sources} = groups[assessment] || props

      sources = cond do
        alternative_id && description ->
          source = sources[alternative_id] || []
          Map.put(sources, alternative_id, [description | source] |> Enum.uniq())

          description ->
            source = sources["None"] || []
            Map.put(sources, "None", [description | source] |> Enum.uniq())

            true ->
              sources
            end
            confidence = item["confidence"] |> String.to_integer()
            seen = item["reporttime"] |> Utils.parse_date()
            group = group
            |> Map.put(:confidence, [confidence | confidence_list])
            |> Map.put(:seen, [seen | seen_list])
            |> Map.put(:sources, sources)
            groups = Map.put(groups, assessment, group)
          end)

          Enum.map(groups, fn({assessment, group = %{seen: seen_list, confidence: confidence_list, sources: sources}}) ->
            %{
              assessment: assessment,
              first_seen: seen_list |> Enum.sort() |> hd() |> Utils.format_date(),
              last_seen: seen_list |> Enum.sort() |> Enum.reverse() |> hd() |> Utils.format_date(),
              highest_confidence: confidence_list |> Enum.sort() |> Enum.reverse() |> hd(),
              average_confidence: div(confidence_list |> Enum.reduce(0, &(&1 + &2)), length(confidence_list)),
              sources: sources |> Enum.map(fn({k, v}) -> {k, Enum.join(v, ", ")} end) |> Enum.into(%{}),
              record_count: map_size(group),
            }
          end)
        end

  defsite sender_base(site, conf) do
    path = conf.resolve_ip_to_site.()

    body = conf.get.("/lookup/", %{"search_string" => path}, [{"tos_accepted", 1330588800}])

    # TODO fix this crap
    auth = if conf.is_ip do
      ~r/authHash = '(.*)'/
      |> Regex.run(body)
      |> Enum.at(1)
    else
      ""
    end

    site_host = if conf.is_ip do
      conf.site
    else
      URI.parse(conf.site) |> Map.get(:host, conf.site)
    end

    output = body
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
        conf.get.("/api/location_for_ip/", %{"search_string" => conf.site, "auth" => auth}, [])
      end,
      "mail_server" => if conf.is_ip do
        conf.get.("/api/mail_servers/", %{"search_string" => site_host, "auth" => auth}, [])
      end
    })

    output
  end

  defsite malc0de(site, conf) do
    conf.get.("/database/index.php", %{"search" => conf.site}, nil)
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
  end

  defsite mc_afee(site, conf) do
    conf.get.("/threat-intelligence/domain/default.aspx", %{"domain" => conf.site}, [])
    |> Transform.clean(remove_tags: ["script", "style", "a"], remove_attrs: [~r/^on/, "src", "href", "style"])
    |> Transform.to_html
    |> Transform.map(fn(x) ->
      %{
        "risk" => x.('//img[@id="ctl00_mainContent_imgRisk"]/@title', 's'),
        "category" => String.strip(x.('//strong[contains(., "Web Category")]/../text()', 's')),
        "last_seen" => String.strip(x.('//strong[contains(., "Last Seen")]/../text()', 's')),
      }
    end)
  end

  defsite rep_auth(site, conf) do
    path = if conf.is_ip do
      "/lookup.php"
    else
      "/domain_lookup.php"
    end

    conf.get.(path, %{"ip" => site}, nil)
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
  end

  defsite safe_browsing(site, conf) do
    body = conf.get.("/lookup", %{
      "client" => "api",
      "apikey" => "ABQIAAAAzO0BeNsWxWi86s2xUZQ1ABTOCj0UZiK_d404jrg3TrlhPfcfBQ",
      "appver" => "1.0",
      "pver" => "3.0",
      "url" => conf.site
    }, nil)

    %{
      "is_phishing" => String.contains?(body, "phishing"),
      "is_malware" => String.contains?(body, "malware"),
      "is_unwanted" => String.contains?(body, "unwanted")
    }
  end

  defp wrap(site, base, func) do
    is_ip = Utils.ip?(site)
    is_domain = !is_ip && Utils.domain?(site)

    get = &Request.get(base <> &1, &2 || [], &3 || [])
    post = &Request.post(base <> &1, &2)

    resolve_ip_to_site = fn ->
      if is_ip do
        site
      else
        "http://ip-api.com/json/#{site}"
        |> Request.get
        |> Map.get("query", nil)
      end
    end

    map = %{
      get: get,
      post: post,
      site: site,
      is_ip: is_ip,
      is_domain: is_domain,
      resolve_ip_to_site: resolve_ip_to_site
    }

    body = func.(map)

    %{
      "is_ip"     =>  is_ip,
      "is_domain" =>  is_domain,
      "body"      =>  body
    }
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
