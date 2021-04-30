defmodule Symbiosis.Server do
  require Logger

  @opts [
    :binary,
    
    packet:    :line,
    active:    false,
    reuseaddr: true
  ]
  
  def child_spec() do
    {Task, &start/0}
  end

  def listen_port() do
    case System.fetch_env("PORT") do
      :error ->
        4000

      {:ok, port} ->
        String.to_integer(port)
    end
  end

  def start() do
    with {:ok, listening} <- :gen_tcp.listen(listen_port(), @opts) do
      Logger.info("Starting server at tcp://0.0.0.0:#{listen_port()}")

      accept(listening)
    else
      {:error, reason} ->
        throw "Error starting server: #{reason}"
    end
  end

  defp accept(listening) do
    with {:ok, accepting} <- :gen_tcp.accept(listening),
         {:ok, pid} <- receive_request(accepting),
          :ok <- :gen_tcp.controlling_process(accepting, pid),
          :ok <- log_peer_details(accepting)
    do
      accept(listening)
    end
  end

  defp receive_request(accepting) do
    Symbiosis.TaskSupervisor
    |> Task.Supervisor.start_child(fn ->
      recv_data(accepting)
    end)
  end

  defp recv_data(accepting) do
    with {:ok, command} <- :gen_tcp.recv(accepting, 0),
         {:ok, result} <- Symbiosis.Command.run(command)
    do
      :gen_tcp.send(accepting, "OK: #{result}\r\n")
      recv_data(accepting)
    else
      {:error, :invalid_command} ->
        :gen_tcp.send(accepting, "ERROR: Invalid command\r\n")
        recv_data(accepting)

        {:error, :not_found} ->
          :gen_tcp.send(accepting, "ERROR: key not found\r\n")
          recv_data(accepting)

      {:error, _reason} ->
        :gen_tcp.close(accepting)
    end
  end

  defp log_peer_details(socket) do
    with {:ok, {client_ip, client_port}} <- :inet.peername(socket),
         client_ip when is_list(client_ip) <- Tuple.to_list(client_ip),
         client_ip when is_binary(client_ip) <- Enum.join(client_ip, ".")
    do
      Logger.info("Received connection from #{client_ip}:#{client_port}")
    end
  end
end