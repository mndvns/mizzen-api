defmodule Api.Supervisor do
  import Supervisor.Spec

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  defp cache(opts) do
    name = opts[:name]
    worker(ConCache, [opts, [name: name]], [id: name])
  end

  defp caches do
    Api.vendors
    |> Enum.map(fn({key, value}) ->
      cache(name: key, ttl: Map.get(value, :ttl, :timer.minutes(5)))
    end)
  end

  def init([]) do
    children = [
    ]
    |> Enum.concat(caches)
    |> Enum.filter(&(&1))

    supervise(children, strategy: :one_for_one)
  end
end
