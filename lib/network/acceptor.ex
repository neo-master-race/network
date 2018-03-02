defmodule Network.Acceptor do
  alias Network.Listener

  def start_link do
    opts = [port: Application.get_env(:network, :port)]
    {:ok, _} = :ranch.start_listener(:network, 100, :ranch_tcp, opts, Listener, [])
  end
end
