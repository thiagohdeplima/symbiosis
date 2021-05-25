defmodule Symbiosis.Command do
  @moduledoc """
  Module for handle and parse
  command strings
  """

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

  @doc """
  Transform a command's string to `Symbiosis.Command` struct

  ### Examples

      iex> Symbiosis.Command.parse("GET key")
      {:ok, %Symbiosis.Command{operation: :get, key: "key", value: :undefined}}

      iex> Symbiosis.Command.parse("INVALID COMMAND")
      {:error, :invalid_command}
  """
  @spec parse(String.t) :: {:ok, __MODULE__.t()} | {:error, any}
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