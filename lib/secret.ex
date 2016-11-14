defmodule Secret do
  @password Application.get_env(:mizzen, :auth_password)
  @sender Application.get_env(:mizzen, :auth_token_secret) |> SimpleSecrets.init()

  def pack(data) do
    SimpleSecrets.pack(data <> ":" <> @password, @sender)
  end

  def pack!(data) do
    SimpleSecrets.pack!(data <> ":" <> @password, @sender)
  end

  def unpack(data) do
    SimpleSecrets.unpack(data, @sender)
  end
end
