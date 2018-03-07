defmodule Network.Application do
  @moduledoc """
  Supervisor of the application.

  Start the ClientRegistry and the Acceptor
  """

  use Application

  def start(_type, _args) do
    children = [
      {Network.ClientRegistry, []},
      {Network.RoomRegistry, []},
      %{
        id: Network.Acceptor,
        start: {Network.Acceptor, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: Network.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
