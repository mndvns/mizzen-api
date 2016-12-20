defmodule Mizzen.Vendors.AlienVault do
  @base_url "https://otx.alienvault.com:443/api/v1/"
  @ip "indicators/IPv4/"
  @domain "indicators/domain/"
  @file_hash "indicators/file/"
  @url "indicators/url/"
  @header ["X-OTX-API-KEY": "14cf51093fa430f0807f0c4bb0b7b36b82c86499de67d242f0900b2a0f656f82"]

  def name, do: "AlienVault"

  def parse_query(query) do
    {Utils.ip?(query), Utils.file_hash?(query), Utils.domain?(query)}
  end

  def get(query) do
    get(query, parse_query(query))
  end
  def get(query, {true, false, false}) do
    for e <- ["/general", "/reputation", "/geo", "/malware", "/url_list", "/passive_dns"] do
      case HTTPoison.get(@base_url <> @ip <> query <> e, @header, [recv_timeout: 10_000]) do
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
  end
  def get(query, {false, true, false}) do
    for e <- ["/general", "/analysis"] do
      case HTTPoison.get(@base_url <> @file_hash <> query <> e, @header, [recv_timeout: 10_000]) do
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
  end
  def get(query, {false, false, true}) do
    for e <- ["/general", "/geo", "/malware", "/url_list", "/passive_dns"] do
      case HTTPoison.get(@base_url <> @domain <> query <> e, @header, [recv_timeout: 10_000]) do
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
  end
  def get(query, {false, false, false}) do
    for e <- ["/general", "/url_list"] do
      case HTTPoison.get(@base_url <> @url <> query <> e, @header, [recv_timeout: 10_000]) do
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
  end
end
