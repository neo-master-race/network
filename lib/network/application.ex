defmodule Network.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Network.TaskSupervisor},
      {Task, fn -> Network.accept(4242) end}
    ]

    opts = [strategy: :one_for_one, name: Network.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
