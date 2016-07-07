defmodule Api.VirusTotal do
  alias Api.VirusTotal.Client

  defdelegate url_report(url), to: Client
  defdelegate ip_address_report(url), to: Client
  defdelegate domain_report(url), to: Client

  def scan(url) do
    cond do
      Utils.ip?(url) ->
        url
        |> ip_address_report
        |> output(true, false)
      Utils.domain?(url) ->
        url
        |> domain_report
        |> output(false, true)
      true ->
        url
        |> url_scan
        |> output(false, false)
    end
  end

  defp output(res, is_ip, is_domain) do
    %{
      "is_ip" => is_ip,
      "is_domain" => is_domain,
      "body" => res |> elem(1) |> transform
    }
  end

  def summarize(%{"body" => :timeout} = res) do
    res
  end
  def summarize(%{"is_ip" => is_ip, "is_domain" => is_domain, "body" => body}) when is_ip or is_domain do
    body
    |> summarize_total("undetected_communicating_samples")
    |> summarize_total("undetected_referrer_samples")
    |> summarize_total("undetected_downloaded_samples")
  end
  def summarize(res) do
    res
  end

  defp summarize_total(body, key) do
    update_in(body, [key], fn(samples) ->
      %{
        "total_positives" => Enum.reduce(samples, 0, &(&1["positives"] + &2)),
        "items" => samples
      }
    end)
  end

  defp transform(value) when not is_list(value) do
    value
  end
  defp transform(list) when is_list(list) do
    case Enum.at(list, 0) do
      nil ->
        []
      {_, _} ->
        Enum.reduce(list, %{}, &(transform(&1, &2)))
      _ ->
        Enum.reduce(list, [], &(&2 ++ [transform(&1)]))
    end
  end
  defp transform({k, v}, acc) do
    Map.put(acc, k, transform(v))
  end

  defp url_scan(url) do
    send(self, Client.url_scan(url))

    receive do
      {:ok, [_, _, _, {_, 1} | _]} ->
        url_report(url)
      _ ->
        %{"error" => "an error occured"}
    end
  end
end
