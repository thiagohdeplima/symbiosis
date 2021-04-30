defmodule Symbiosis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Symbiosis.DataHandler, []},

      {Task.Supervisor, name: Symbiosis.TaskSupervisor},

      Supervisor.child_spec(Symbiosis.Server.child_spec(), restart: :permanent),
    ]

    Supervisor.start_link(children, [
      strategy: :one_for_one,
      name: Symbiosis.Supervisor
    ])
  end
end
