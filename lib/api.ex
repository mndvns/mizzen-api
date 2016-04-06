defmodule Api do
  use Application

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
      {:ok, _sup} = Elixir.Supervisor.start_link(__MODULE__, [], name: :supervisor)
    end

    def init(_opts) do
      {:ok, {{:one_for_one, 10, 10}, []}}
    end
  end
end
