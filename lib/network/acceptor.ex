defmodule Network.Acceptor do
  @moduledoc """
  Listen for connections.
  """
  require Logger
  alias Network.Listener

  @doc """
  Start listening to the port defined in the configuration file, and accept connections.

  Can fail if the port is already used or if it doesn't have the right to listen to that port.
  """
  def start_link do
    port = Application.get_env(:network, :port)
    opts = [port: port]

    Logger.info("accepting connections on port #{port}")

    :ranch.start_listener(:network, 100, :ranch_tcp, opts, Listener, [])
  end
end
