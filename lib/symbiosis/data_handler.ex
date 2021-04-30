defmodule Symbiosis.DataHandler do
  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(_state) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def handle_call(%{operation: "SET", key: key, value: value}, _from, state) do
    {:reply, {key, value}, state}
  end

  @impl true
  def handle_call(%{operation: "GET", key: key}, _from, state) do
    {:reply, {key}, state}
  end

  @impl true
  def handle_call(%{operation: "DELETE", key: key}, _from, state) do
    {:reply, {key}, state}
  end
end