defmodule Plug.Auth do
  @behaviour Plug
  @password Application.get_env(:mizzen, :auth_password)
  @id Application.get_env(:mizzen, :auth_id)

  def init([]) do
    []
  end

  def call(conn, opts) do
    parse(conn)
  end

  defp parse(conn = %{private: %{authenticated: _}}) do
    conn
  end
  defp parse(conn) do
    user = case Plug.Conn.get_req_header(conn, "authorization") do
      [<<"Bearer ", token :: binary>>] ->
        decode(token, &Secret.unpack/1)
      [<<"Basic ", token :: binary>>] ->
        decode(token, &Base.decode64/1)
      [token] ->
        decode(token, &Secret.unpack/1)
      _ -> nil
    end
    conn
    |> Plug.Conn.put_private(:authenticated_user, user)
    |> Plug.Conn.put_private(:authenticated, is_binary(user))
  end

  defp decode(token, fun) do
    try do
      apply(fun, [token])
    rescue
      exception ->
        nil
    else
      decoded when is_binary(decoded) ->
        case String.split(decoded, ":") do
          [user, @password] ->
            true
          @id ->
            true
          _ ->
            nil
        end
      _ ->
        nil
    end
  end
end
