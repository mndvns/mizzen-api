defmodule RequestStore do
  def new do
    Agent.start_link(fn -> [] end)
  end

  def add(pid, new_value) do
    Agent.update(pid, fn(state) -> state ++ [new_value] end)
  end

  def get(pid) do
    Agent.get(pid, fn(state) -> state end)
  end
end
