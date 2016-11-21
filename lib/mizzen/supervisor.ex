defmodule Mizzen.Supervisor do
  use Supervisor

  def start_link() do
    {:ok, _sup} = Supervisor.start_link(__MODULE__, [], name: :supervisor)
  end

  def init(_) do
    processes = [
      Supervisor.Spec.worker(Cachex, [:url, [
        ttl: :timer.hours(1),
        ttl_interval: :timer.minutes(1),
      ]])
    ]
    {:ok, {{:one_for_one, 10, 10}, processes}}
  end
end
