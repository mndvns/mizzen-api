defmodule Site do
  require Transform
  require Floki
  require Request
  require IEx

  @safe_browsing_key System.get_env() |> Map.get("SAFE_BROWSING_KEY")

  def malc0de(site, base) do
    uri = Request.uri(base <> "/database/index.php", %{"search" => site})
    body = Request.get(uri)

    output = body
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

    %{
      "link" => uri,
      "data" => output
    }
  end

  def mc_afee(site, base) do
    uri = Request.uri(base <> "/threat-intelligence/domain/default.aspx", %{"domain" => site})
    body = Request.get(uri)

    output = body
    |> Transform.clean(remove_tags: ["script", "style"], remove_attrs: [~r/^on/, "src", "href", "style"])
    |> Transform.to_html
    |> Transform.map(fn(x) ->
      %{
        "risk" => x.('//img[@id="ctl00_mainContent_imgRisk"]/@title', 's'),
        "category" => String.strip(x.('//strong[contains(., "Web Category")]/../text()', 's')),
        "last_seen" => String.strip(x.('//strong[contains(., "Last Seen")]/../text()', 's')),
      }
    end)

    %{
      "link" => uri,
      "data" => output
    }
  end

  def rep_auth(site, base) do
    uri = Request.uri(base <> "/lookup.php", %{"ip" => site})
    body = Request.get_json(uri)

    output = body
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

    %{
      "link" => uri,
      "data" => output
    }
  end

  def safe_browsing(site, base) do
    uri = Request.uri(base <> "/lookup", %{
      "client" => "api",
      "apikey" => @safe_browsing_key,
      "appver" => "1.0",
      "pver" => "3.0",
      "url" => site
    })
    body = Request.get(uri)

    output = %{
      "is_phishing" => String.contains?(body, "phishing"),
      "is_malware" => String.contains?(body, "malware"),
      "is_unwanted" => String.contains?(body, "unwanted")
    }

    %{
      "link" => uri,
      "data" => output
    }
  end

  def sender_base(site, base) do
    uri = Request.uri(base <> "/lookup/", %{"search_string" => site, "tos_accepted" => "Yes, I Agree"})
    body = Request.get(uri)

    {_, _, [string]} = Floki.find(body, "script")
    |> Enum.filter(fn({_tag, attrs, _children}) -> length(attrs) == 0 end)
    |> Enum.filter(fn({_tag, _attrs, [firstLine | _]}) -> String.contains?(firstLine, "authHash") end)
    |> hd

    [_ | [auth]] = Regex.run(~r/authHash\s?=\s?["'](.*)["']/, string)

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

    output = Map.merge(output, %{
      "geolocation" => Request.get_json("http://www.senderbase.org/api/location_for_ip/", %{"search_string" => site, "auth" => auth}),
      "mail_server" => Request.get_json("http://www.senderbase.org/api/mail_servers/", %{"search_string" => site, "auth" => auth}),
    })

    %{
      "link" => uri,
      "data" => output
    }
  end

  def take(list, columns) do
    take(list, columns, [])
  end
  def take([], _columns, acc) do
    acc
  end
  def take(list, columns, acc) do
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
