defmodule Network.Listener do
  require Logger

  alias Network.Worker
  alias Network.ClientRegistry

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)

    id = Port.info(socket)[:id]
    {:ok, worker_pid} = Worker.start_link(socket, transport, id)

    Logger.debug("client #{id} connected (listener=#{inspect self()}, worker=#{inspect worker_pid}).")

    listen(socket, transport, worker_pid)
  end

  def listen(socket, transport, worker_pid) do
    # timeout at 2min
    case transport.recv(socket, 0, 2 * 60 * 1_000) do
      {:ok, msg} ->
        :ok = Worker.handle_msg(worker_pid, String.trim(msg))
        listen(socket, transport, worker_pid)
      _ ->
        state = GenServer.call(worker_pid, :inspect)
        Logger.debug("socket for client #{state.id} closed.")
        :ok = transport.close(socket)
        ClientRegistry.unregister(state.id)
    end
  end
end
