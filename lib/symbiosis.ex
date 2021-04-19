defmodule Symbiosis do
  require Logger

  @opts [
    :binary,
    
    packet:    :line,
    active:    false,
    reuseaddr: true
  ]

  defstruct [
    :listening,
    :accepting,
    :callback
  ]
  
  def start_tcp(port \\ 4000) do
    with {:ok, listening} <- :gen_tcp.listen(port, @opts),
         {:ok, accepting} <- :gen_tcp.accept(listening)
    do
      %__MODULE__{}
      |> Map.put(:listening, listening)
      |> Map.put(:accepting, accepting)
      |> Map.put(:callback,  &recv_data/1)
      |> recv_data()
    else
      {:error, reason} ->
        throw "Error starting server: #{reason}"
    end
  end

  defp accept(%__MODULE__{listening: listening} = settings) do
    case :gen_tcp.accept(listening) do
      {:ok, accepting} ->
        settings
        |> Map.put(:accepting, accepting)
        |> recv_data()

      {:error, reason} ->
        throw "Error starting server: #{reason}"
    end
  end

  defp recv_data(%__MODULE__{accepting: socket} = settings) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, command} ->
        command
        |> process_command(settings)

      {:error, reason} ->
        Logger.error("Error receiving data: #{reason}")
        settings.callback.(settings)
    end
  end

  defp process_command("CLOSE\r\n", %__MODULE__{accepting: socket} = settings) do
    case :gen_tcp.close(socket) do
      :ok ->
        accept(settings)

      {:error, reason} ->
        Logger.error("Error closing connection: #{reason}")
        accept(settings)
    end
  end
  defp process_command(command, %__MODULE__{accepting: socket} = settings) do
    case :gen_tcp.send(socket, "Received command #{command}") do
      :ok ->
        settings.callback.(settings)

      {:error, reason} ->
        Logger.error("Error sending response: #{reason}")
    end
  end
end
