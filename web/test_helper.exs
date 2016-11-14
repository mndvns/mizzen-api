defmodule Test.Mizzen.Resource do
  defmodule AffordanceProxy do
    use Mizzen.Resource

    mediatype Hyper do
      provides "application/json"

      action do
        subject = var!(conn).private.mazurka_affordance_test_subject
        link_to(subject, Params.get(), Input.get())
      end
    end
  end

  defmacro __using__(_) do
    resource = __CALLER__.module |> Module.split() |> tl() |> Module.concat()
    quote do
      @router Mizzen.Router
      use Fugue, plug: @router
      import unquote(__MODULE__)
      require unquote(resource)
      @subject unquote(resource)

      defp prepare_request(conn, context) do
        {method, path_info} = @router.resolve(@subject, conn.private[:mizzen_test_params] || %{})

        request_path = "/" <> Enum.join(path_info, "/")
        body = conn.private[:mizzen_test_body]

        conn
        |> Plug.Adapters.Test.Conn.conn(method, request_path, body)
        |> Map.put(:remote_ip, conn.remote_ip || {127, 0, 0, 1})
        |> Map.put(:query_string, conn.private[:mizzen_test_query] || "")
      end
    end
  end

  defmacro affordance(body \\ [do: nil]) do
    quote do
      conn = request(unquote(body))

      conn
      |> Plug.Conn.put_private(:mazurka_affordance_test_subject, @subject)
      |> Plug.Conn.put_private(:mazurka_route, Test.Mizzen.Resource.AffordanceProxy)
      |> Map.put(:params, conn.private[:mizzen_test_params] || %{})
    end
  end

  defmacro params(params) do
    quote do
      var!(conn) = Plug.Conn.put_private(var!(conn), :mizzen_test_params, unquote(params))
    end
  end

  defmacro body(content) do
    quote do
      var!(conn) = case unquote(content) do
        content when is_map(content) ->
          var!(conn) = Plug.Conn.put_private(var!(conn), :mizzen_test_body, Poison.encode!(content))
          header("content-type", "application/json")
          var!(conn)
      end
    end
  end

  defmacro cookie(key, value) do
    quote do
      header "cookie", URI.encode_query(Map.put(%{}, unquote(key), unquote(value)))
    end
  end

  defmacro query(content) do
    quote do
      var!(conn) = case unquote(content) do
        content when is_map(content) ->
          Plug.Conn.put_private(var!(conn), :mizzen_test_query, URI.encode_query(content))
      end
    end
  end

  defmacro seed(module, params \\ Macro.escape(%{})) do
    quote do
      unquote(module).seed(unquote(params))
    end
  end

  for call <- [:assert, :refute] do
    defmacro unquote(:"#{call}_json")(conn, match) do
      call = unquote(call)

      quote do
        conn = unquote(conn)
        parsed_body = conn.private[:parsed_body] || Poison.decode!(conn.resp_body)
        conn = Plug.Conn.put_private(conn, :parsed_body, parsed_body)

        unquote(:"#{call}_term_match")(parsed_body, unquote(match), "Expected JSON response body to match")

        conn
      end
    end

    defmacro unquote(:"#{call}_transition")(conn, location) when is_binary(location) do
      call = unquote(call)
      quote do
        conn = unquote(conn)
        location = unquote(location)
        location = if location == :proplists.get_value("location", conn.resp_headers) || location =~ ~r|://| do
          location
        else
          %URI{scheme: to_string(conn.scheme || "http"), host: conn.host, port: conn.port, path: location} |> to_string()
        end

        ExUnit.Assertions.unquote(call)(:proplists.get_value("location", conn.resp_headers) == location)
        conn
      end
    end
    defmacro unquote(:"#{call}_transition")(conn, resource, params \\ Macro.escape(%{}), query \\ Macro.escape(%{}), fragment \\ nil) do
      call = unquote(call)

      resource = quote do
        r = unquote(resource)
        @router.resolve_module(r) || r
      end

      match = {:{}, [], [resource, params, query, fragment]}

      quote do
        conn = unquote(conn)

        actual =
          case :proplists.get_value("location", conn.resp_headers) do
            :undefined ->
              {nil, nil, nil, nil}
            transition ->
              transition = URI.parse(transition)
              [_ | path_info] = transition.path |> String.split("/")
              case @router.match("GET", path_info) do
                {module, params} ->
                # TODO implement query
                {module, params, %{}, transition.fragment}
                _ ->
                  {nil, nil, nil, nil}
              end
          end

        unquote(:"#{call}_term_match")(actual, unquote(match), "Expected transition to match")

        conn
      end
    end

    def unquote(:"#{call}_invalidates")(conn, _url) do
      ## TODO
      conn
    end
  end
end

ExUnit.start()
