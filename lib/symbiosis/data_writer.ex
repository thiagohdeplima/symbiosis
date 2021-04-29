defmodule Symbiosis.DataWriter do
  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def handle_call({:set, key, value}, _from, state) do
    {:reply, true, state}
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    {:reply, true, state}
  end
end