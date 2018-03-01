defmodule Network.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:network, :port)

    children = [
      {Task.Supervisor, name: Network.TaskSupervisor},
      {Task, fn -> Network.accept(port) end}
    ]

    opts = [strategy: :one_for_one, name: Network.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
