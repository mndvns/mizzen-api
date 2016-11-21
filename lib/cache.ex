defmodule Mizzen.Cache do
  def get(fun, [q | _]) when q in ["", nil, false] do
    nil
  end
  def get(fun, [q | _] = args) do
    module = :erlang.fun_info(fun)[:module]
    {status, data} = Cachex.get(:url, {module, q}, fallback: fn(_) ->
      try do
        apply(fun, args)
      catch
        _ ->
          %{
            "error" => "an error occurred"
          }
      else
        body ->
          %{
            "body" => body,
            "name" => apply(module, :name, []),
            "retrieved_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
           }
      end
    end)

    data
  end
end
