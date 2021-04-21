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
          :ok <- :gen_tcp.controlling_process(accepting, pid)
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
         {:ok, result} <- Symbiosis.Command.run(command)
    do
      recv_data(settings)
    else
      {:error, reason} ->
        :gen_tcp.close(socket)
    end
  end
end
