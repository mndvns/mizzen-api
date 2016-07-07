defmodule Api do
  @vendors Application.get_env(:api, :vendors)

  use Application

  def vendors, do: @vendors
  def vendors(name), do: @vendors[name]

  def start(_type, _args) do
    Mix.env == :dev && PoeApi.Dev.start()
    HTTPoison.start()
    __MODULE__.HTTP.start([])
    __MODULE__.Supervisor.start_link()
  end

  defmodule Supervisor do
    use Elixir.Supervisor
    import Elixir.Supervisor.Spec

    def start_link() do
      Elixir.Supervisor.start_link(__MODULE__, [], name: :supervisor)
    end

    defp cache([{:name, name} | _] = opts) do
      worker(ConCache, [[], opts], [id: name])
    end

    def init([]) do
      children = for {key, value} <- Api.vendors do
        cache(name: key, ttl: Map.get(value, :ttl, :timer.minutes(5)))
      end

      supervise(children, strategy: :one_for_one)
    end
  end
end
