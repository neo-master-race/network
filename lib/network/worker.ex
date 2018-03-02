defmodule Network.Worker do
  use GenServer
  require Logger

  alias Network.ClientRegistry

  def start_link(socket, transport, id) do
    default_state = %{
      socket: socket,
      transport: transport,
      id: id
    }

    GenServer.start_link(__MODULE__, default_state)
  end

  def init(default) do
    ClientRegistry.register({default.id, self()})
    {:ok, default}
  end

  def send_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:send_msg, msg})
  end

  def handle_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:handle_msg, msg})
  end

  def handle_call({:handle_msg, msg}, _from, state) do
    Logger.debug("client #{inspect state.id} sent message: #{inspect msg}")

    ClientRegistry.get_entries
    |> Stream.reject(fn {id, _pid} -> id == state.id end) # do not send to the sender
    |> Enum.each(fn {_id, pid} -> send_msg(pid, msg) end)

    {:reply, :ok, state}
  end

  def handle_call({:broadcast_msg, msg}, from, state) do
    Logger.debug("client #{inspect state.id} broadcasted message: #{inspect msg}")
    handle_call({:handle_msg, msg}, from, state)
    handle_call({:send_msg, msg}, from, state)

    {:reply, :ok, state}
  end

  def handle_call({:send_msg, msg}, _from, state) do
    state.transport.send(state.socket, msg)
    {:reply, :ok, state}
  end

  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end
end
