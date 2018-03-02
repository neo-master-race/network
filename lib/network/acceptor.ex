defmodule Network.Acceptor do
  require Logger
  alias Network.Listener

  def start_link do
    port = Application.get_env(:network, :port)
    opts = [port: port]

    Logger.debug("accepting connections on port #{port}")

    try do
      {:ok, _} = :ranch.start_listener(:network, 100, :ranch_tcp, opts, Listener, [])
    rescue
      _ ->
        Logger.error(
          "something is already listening on port #{port} or you don't have the right to listen to it."
        )
    end
  end
end
