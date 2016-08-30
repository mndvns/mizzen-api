defmodule Api.Resource do
  defmacro __using__(_opts) do
    quote do
      use Mazurka.Resource
      alias Plug.Conn
      import unquote(__MODULE__)
    end
  end

  defmacro hyper([do: block]) do
    quote do
      mediatype Hyper do
        unquote(block)
      end
    end
  end

  defmacro error(code_or_message) do
    error_response(code_or_message)
  end
  defmacro error(code, message) do
    error_response(code, message)
  end

  def error_response(code_or_message) do
    code_or_message
    |> Utils.HTTPCodes.status()
    |> error_response_format
  end
  def error_response(code, message) do
    code
    |> Utils.HTTPCodes.status()
    |> Map.put(:message, message)
    |> error_response_format
  end

  def error_response_format(%{code: code, message: message}) do
    quote do
      status unquote(code)
      %{
        "error" => %{
          "message" => unquote(message)
        }
      }
    end
  end

  defmacro point_to(path, params \\ [], input \\ [])
  defmacro point_to(path, params, input) do
    resolve_affordance(path, params, input)
  end

  # TODO for some reason, an empty list of params fails. an empty map works, however
  defp resolve_affordance(path, params, input) when is_list(params) do
    params = params
    |> Enum.into(%{})
    |> Macro.escape()
    resolve_affordance(path, params, input)
  end
  defp resolve_affordance(path, params, input) do
    quote do
      params = unquote(params)
      |> Enum.map(fn({k, v}) -> {to_string(k), v} end)
      |> Enum.into(%{})
      %{
        "href" => %Mazurka.Affordance{
          resource: unquote(path),
          params: params,
          input: unquote(input),
        }
        |> Api.HTTP.Router.resolve(%{}, conn)
        |> to_string()
      }
    end
  end

  defmacro conn do
    Mazurka.Resource.Utils.conn
  end

  defmacro status(code) do
    quote do
      var!(conn) = conn = Plug.Conn.put_status(var!(conn), unquote(code))
    end
  end

  defmacro inputs do
    quote do
      conn.params
    end
  end
end
