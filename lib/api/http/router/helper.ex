defmodule Api.HTTP.Router.Helper do
  defmacro __using__(_) do
    quote do
      use Plug.Builder
      use Concerto, [root: "#{System.cwd!}/web",
                     ext: ".ex",
                     module_prefix: Api.Resource]

      import unquote(__MODULE__)

      def call(conn, opts) do
        try do
          super(conn, opts)
        catch
          _kind, %Poison.EncodeError{} ->
            error_response(conn, :bad_request)
          _kind, %Mazurka.ConditionException{message: message} ->
            error_response(conn, message)
        end
      end

      defp error_response(conn, {code, message}) do
        code
        |> Utils.HTTPCodes.status()
        |> Map.put(:message, message)
        |> error_response_format(conn)
      end
      defp error_response(conn, code_or_message) do
        code_or_message
        |> Utils.HTTPCodes.status()
        |> error_response_format(conn)
      end

      defp error_response_format(%{code: code, message: message}, conn) do
        body = %{"error" => %{"message" => message}}
        content_type = {"application", "json", nil}
        conn
        |> handle_body(body, content_type)
        |> put_status(code)
        |> send_resp
      end

      def match(%{private: %{mazurka_route: _}} = conn, _opts) do
        conn
      end
      def match(%Plug.Conn{} = conn, _opts) do
        case match(conn.method, conn.path_info) do
          {module, params} ->
            conn
            |> put_private(:mazurka_route, module)
            |> put_private(:mazurka_resource, module)
            |> put_private(:mazurka_params, params)
          nil ->
            conn
            |> put_private(:mazurka_route, Api.Resource.Error.GET)
            |> put_private(:mazurka_resource, Api.Resource.Error.GET)
            |> put_private(:mazurka_params, %{})
        end
      end

      defp dispatch(conn, _opts) do
        {body, content_type, conn} = conn
        |> handle_accept_header()
        |> handle_action()

        conn
        |> handle_body(body, content_type)
        |> handle_transition()
        |> handle_invalidation()
        |> handle_response()
        |> send_resp()
      end

      def resolve(affordance = %{resource: resource, params: params}, source, conn) do
        case resolve(resource, params) do
          {method, path} ->
            %{affordance |
              host: conn.host,
              port: conn.port,
              scheme: conn.scheme |> to_string,
              method: method,
              path: "/" <> (Stream.concat(conn.script_name, path) |> Enum.join("/")),
              fragment: affordance.opts[:fragment],
              query: case URI.encode_query(affordance.input) do
                "" -> nil
                other -> other
              end
            }
          nil ->
            nil
          other ->
            other
        end
      end

      def resolve_resource(resource_name, _source, _conn) do
        resolve_module(resource_name)
      end

      defp handle_accept_header(conn) do
        accepts = conn
        |> Plug.Conn.get_req_header("accept")
        |> Stream.map(&Plug.Conn.Utils.list/1)
        |> Stream.concat()
        |> Stream.map(fn(type) ->
          case Plug.Conn.Utils.media_type(type) do
            {:ok, type, subtype, params} ->
              {type, subtype, params}
            _ ->
              nil
          end
        end)
        |> Stream.filter(&!is_nil(&1))
        |> Enum.to_list()
        Plug.Conn.put_private(conn, :mazurka_accepts, accepts)
      end

      defp handle_action(%{private: %{mazurka_route: route, mazurka_params: params, mazurka_accepts: accepts}} = conn) do
        conn = %{params: input} = fetch_query_params(conn)
        route.action(accepts, params, input, conn, __MODULE__)
      end

      defp handle_body(conn, body, content_type) do
        body = case content_type do
          {"application", subtype, _} when subtype in ["json", "hyper+json"] ->
            body |> Poison.encode!
          {"text", _, _} ->
            body
        end
        %{conn | resp_body: body, state: :set}
      end

      defp handle_transition(conn = %{private: %{mazurka_transition: transition}, status: status}) do
        %{conn | status: status || 303}
        |> put_resp_header("location", to_string(transition))
      end
      defp handle_transition(conn) do
        conn
      end

      defp handle_invalidation(conn = %{private: %{mazurka_invalidations: invalidations}}) do
        Enum.reduce(invalidations, conn, &(put_resp_header(&2, "x-invalidates", &1)))
      end
      defp handle_invalidation(conn) do
        conn
      end

      defp handle_response(conn = %{status: status}) do
        %{conn | status: status || 200}
      end
    end
  end
end
