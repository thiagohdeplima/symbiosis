defmodule Symbiosis.DataHandler do
  use GenServer

  @impl true
  def init(_), do: {:ok, %{}}

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def handle_call(%{operation: "SET", key: key, value: value}, _from, state) do
    {:reply, {:ok, :set}, Map.put(state, key, value)}
  end

  @impl true
  def handle_call(%{operation: "GET", key: key}, _from, state) do
    case Map.get(state, key) do
      nil ->
        {:reply, {:error, :not_found}, state}

      val ->
        {:reply, {:ok, val}, state}
    end
  end

  @impl true
  def handle_call(%{operation: "DELETE", key: key}, _from, state) do
    {:reply, {:ok, :delete}, Map.drop(state, [key])}
  end
end