defmodule Symbiosis.Server do
  require Logger

  @opts [
    :binary,
    
    packet:    :line,
    active:    false,
    reuseaddr: true
  ]

  defstruct [
    :listening,
    :accepting
  ]
  
  def child_spec() do
    {Task, &start_server/0}
  end

  def start_server() do
    with {:ok, listening} <- :gen_tcp.listen(4000, @opts) do
      Logger.info("Accepting requests on tcp://0.0.0.0:4000")

      %__MODULE__{}
      |> Map.put(:listening, listening)
      |> accept()
    else
      {:error, reason} ->
        throw "Error starting server: #{reason}"
    end
  end

  defp accept(%__MODULE__{listening: listening} = settings) do
    with {:ok, accepting} <- :gen_tcp.accept(listening),
         {:ok, pid} <- receive_request(accepting, settings),
          :ok <- :gen_tcp.controlling_process(accepting, pid),
          :ok <- log_peer_details(accepting)
    do
      accept(settings)
    end
  end

  defp receive_request(accepting, settings) do
    Task.Supervisor.start_child(Symbiosis.TaskSupervisor, fn ->
      settings
      |> Map.put(:accepting, accepting)
      |> recv_data()
    end)
  end

  defp recv_data(%__MODULE__{accepting: socket} = settings) do
    with {:ok, command} <- :gen_tcp.recv(socket, 0),
         {:ok, _result} <- Symbiosis.Command.run(command)
    do
      recv_data(settings)
    else
      {:error, _reason} ->
        :gen_tcp.close(socket)
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