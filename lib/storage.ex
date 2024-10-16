defmodule Storage do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def add_data(%{} = data) do
    Agent.update(__MODULE__, &Map.merge(&1, data))
  end

  def get_data() do
    Agent.get(__MODULE__, & &1)
  end

  def get_key(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
