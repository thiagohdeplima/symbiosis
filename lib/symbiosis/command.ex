defmodule Symbiosis.Command do
  defstruct [
    :key,
    :operation,

    value: :undefined,
  ]

  @type t :: %__MODULE__{
    key:   String.t(),
    value: String.t() | :undefined,

    operation: String.t(),
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
  defp parse("SET" <> _ = command) do
    ~r/^(?<operation>SET)\s(?<key>\w+)\s(?<value>\w+)$/
    |> Regex.named_captures(command)
    |> case do
      nil -> {:error, :invalid_command}

      %{"operation" => operation, "key" => key, "value" => value} ->
        {:ok, %__MODULE__{operation: operation, key: key, value: value}}
    end
  end
  defp parse(command) do
    ~r/^(?<operation>GET|DELETE)\s(?<key>\w+)$/
    |> Regex.named_captures(command)
    |> case do
      nil -> {:error, :invalid_command}

      %{"operation" => operation, "key" => key} ->
        {:ok, %__MODULE__{operation: operation, key: key}}
    end
  end
end