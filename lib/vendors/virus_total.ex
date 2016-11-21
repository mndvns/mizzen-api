defmodule Mizzen.Vendors.VirusTotal do
  alias Mizzen.Vendors.VirusTotal.Client

  def name, do: "Virus Total"

  defdelegate url_report(url), to: Client
  defdelegate ip_address_report(url), to: Client
  defdelegate domain_report(url), to: Client
  defdelegate file_report(url), to: Client

  def scan(url, {true, _, _}) do
    ip_address_report(url) |> elem(1)
  end
  def scan(url, {_, true, _}) do
    file_report(url) |> elem(1)
  end
  def scan(url, {_, _, true}) do
    domain_report(url) |> elem(1)
  end
  def scan(url, _) do
    url_scan(url) |> elem(1)
  end

  defp url_scan(url) do
    send(self, Client.url_scan(url))

    receive do
      {:ok, [_, _, _, {_, 1} | _]} ->
        url_report(url)
      _ ->
        %{"error" => "An error occured"}
    end
  end
end
