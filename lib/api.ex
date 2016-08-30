defmodule Api do
  use Application
  require Logger

  @vendors Application.get_env(:api, :vendors)

  def vendors, do: @vendors
  def vendors(name), do: @vendors[name]

  def start(_type, _args) do
    if Mix.env == :dev do
      dev()
    end
    Api.HTTP.start()
    Api.Supervisor.start_link()
  end

  def dev do
    :rl.cmd(['src/**/*.erl', 'mix compile.erlang'])
    :rl.cmd(['.iex.exs', 'mix compile'])
    :rl.cmd(['lib/**/*.ex', 'mix compile'])
    :rl.cmd(['web/**/*.ex*', 'mix compile'])
    :rl.error_handler(fn({ {exception = %{:__struct__ => name}, stacktrace}, _}, _file) ->
      Logger.error("** (#{name}) #{Exception.message(exception)}")
      Logger.error(Exception.format_stacktrace(stacktrace))
    end)
  end
end
