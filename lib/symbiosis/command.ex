defmodule Symbiosis.Command do
  defstruct [
    :key,
    :operation,

    value: :undefined,
  ]

  @type operation :: :set | :get | :delete

  @type t :: %__MODULE__{
    key:   String.t(),
    value: String.t() | :undefined,

    operation: operation
  }

  def run(command) do
    case parse(command) do
      {:ok, command = %__MODULE__{}} ->
        GenServer.call(Symbiosis.DataHandler, command)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec parse(String.t) :: __MODULE__.t()
  def parse("SET" <> _ = command) do
    ~r/^(?<operation>SET)\s(?<key>\w+)\s(?<value>\w+)$/
    |> Regex.named_captures(command)
    |> case do
      nil -> {:error, :invalid_command}

      %{"key" => key, "value" => value} ->
        {:ok, %__MODULE__{operation: :set, key: key, value: value}}
    end
  end
  def parse(command) do
    ~r/^(?<operation>GET|DELETE)\s(?<key>\w+)$/
    |> Regex.named_captures(command)
    |> case do
      nil -> {:error, :invalid_command}

      %{"operation" => "GET", "key" => key} ->
        {:ok, %__MODULE__{operation: :get, key: key}}

      %{"operation" => "DELETE", "key" => key} ->
        {:ok, %__MODULE__{operation: :delete, key: key}}
    end
  end
end