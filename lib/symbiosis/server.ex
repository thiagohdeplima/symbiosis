defmodule Symbiosis.Server do
  require Logger

  @opts [
    :binary,
    
    packet:    :line,
    active:    false,
    reuseaddr: true
  ]
  
  def child_spec() do
    {Task, &start_server/0}
  end

  def start_server() do
    with {:ok, listening} <- :gen_tcp.listen(4000, @opts) do
      Logger.info("Starting server at tcp://0.0.0.0:4000")

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
    Task.Supervisor.start_child(Symbiosis.TaskSupervisor, fn ->
      recv_data(accepting)
    end)
  end

  defp recv_data(accepting) do
    with {:ok, command} <- :gen_tcp.recv(accepting, 0),
         {:ok, _result} <- Symbiosis.Command.run(command)
    do
      recv_data(accepting)
    else
      {:error, _reason} ->
        :gen_tcp.close(accepting)
    end
  end

  defp log_peer_details(socket) do
    with {:ok, {host, port}} <- :inet.peername(socket),
         host when is_list(host) <- Tuple.to_list(host),
         host when is_binary(host) <- Enum.join(host, ".")
    do
      Logger.info("Connected with host #{host}:#{port}")
    end
  end
end