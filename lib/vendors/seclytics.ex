defmodule Mizzen.Vendors.Seclytics do
  @base_url "https://api.seclytics.com/"
  @ip "ips/"
  @cidr "cidrs/"
  @asn "asns/"
  @file "files/"
  @host "hosts/"
  @token "?access_token=4rQUEYrAExnHBSx3qwME4qiJ"
  @header ["Authorization": "4rQUEYrAExnHBSx3qwME4qiJ"]

  def name, do: "Seclytics"

  def get(query) do
    get(query, Utils.parse_query(query))
  end
  def get(query, {true, false, false}) do
    case HTTPoison.get(@base_url <> @ip <> query <> @token, [], [recv_timeout: 10_000]) do
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
  def get(query, {false, true, false}) do
    # TODO: using the attribute `@file` raises an elixir error, need to create an issue with the developers.

    # case HTTPoison.get(@base_url <> @file <> query, @header, [recv_timeout: 10_000]) do

    # == Compilation error on file lib/vendors/seclytics.ex ==
    #   ** (CompileError) lib/vendors/seclytics.ex:30: invalid literal nil in <<>>
    # (elixir) src/elixir_bitstring.erl:149: :elixir_bitstring.build_bitstr/4
    # (stdlib) lists.erl:1354: :lists.mapfoldl/3
    case HTTPoison.get(@base_url <> "files/" <> query <> @token, [], [recv_timeout: 10_000]) do
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
  def get(query, {false, false, true}) do
    case HTTPoison.get(@base_url <> @host <> query <> @token, [], [recv_timeout: 10_000]) do
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
