defmodule Symbiosis.Command do
  defstruct [
    :key,
    :operation,

    value: :undefined,
  ]

  def run(command) do
    case parse(command) do
      {:ok, %__MODULE__{}} ->
        {:ok, command}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse(<<"SET", _>> = command) do
    ~r/^(?<operation>SET)\s(?<key>\w+)\s(?<value>\w+)$/
    |> Regex.named_captures(command)
    |> case do
      nil -> {:error, :invalid_command}

      %{"operation" => operation, "key" => key, "value" => value} ->
        {:ok, %__MODULE__{operation: operation, key: key}}
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