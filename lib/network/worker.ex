defmodule Network.Worker do
  use GenServer
  require Logger

  alias Network.ClientRegistry

  def start_link(socket, transport, id) do
    default_state = %{
      socket: socket,
      transport: transport,
      id: id,
      buffer: ""
    }

    GenServer.start_link(__MODULE__, default_state)
  end

  def init(default) do
    ClientRegistry.register({default.id, self()})
    {:ok, default}
  end

  @doc """
  Send a message `msg` to the client having pid = `pid`
  """
  def send_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:send_msg, msg})
  end

  def handle_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.call(pid, {:handle_msg, msg})
  end

  @doc """
  Handle an incoming `message` that needs to be sent to all other registred clients
  """
  def handle_message(message, state) do
    case Messages.decode(message) do
      {:chat_message, data} ->
        %{user: user, content: content} = data
        Logger.debug("client #{inspect(state.id)} as #{user} sent message: #{inspect(content)}")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:update_player_position, _data} ->
        Logger.debug("got an update player position message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      _ ->
        Logger.warn("cannot decode message: #{String.trim(message)}")
    end
  end

  @doc """
  Handling the `buffer` when getting some datas.

  Useful when many messages are coming at the same time, or if messages are too long.
  """
  def handle_buffer(buffer, state) do
    case buffer do
      <<len::little-unsigned-32, message::binary-size(len)>> <> rest ->
        handle_message(message, state)
        handle_buffer(rest, state)

      buffer ->
        buffer
    end
  end

  @doc """
  Handle an incoming message `msg`
  """
  def handle_call({:handle_msg, msg}, _from, %{buffer: buffer} = state) do
    buffer = handle_buffer(buffer <> msg, state)
    {:reply, :ok, %{state | buffer: buffer}}
  end

  @doc """
  Broadcast a message `msg`
  """
  def handle_call({:broadcast_msg, msg}, from, state) do
    Logger.debug("client #{inspect(state.id)} broadcasted a message.")
    # all but the sender
    handle_message(msg, state)
    # to the sender
    handle_call({:send_msg, msg}, from, state)

    {:reply, :ok, state}
  end

  @doc """
  Send a message `msg` to the client of this worker
  """
  def handle_call({:send_msg, msg}, _from, state) do
    message = <<byte_size(msg)::little-unsigned-32>> <> msg
    state.transport.send(state.socket, message)
    {:reply, :ok, state}
  end

  @doc """
  Returns the current `state` of the worker
  """
  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end

  # Room
  # def createRoom() do
  # end
  # def join() do
  # end
  # def updatePositon() do
  # end
end
