defmodule Network.Worker do
  use GenServer
  require Logger

  alias Network.ClientRegistry
  alias Network.Room

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
    GenServer.cast(pid, {:send_msg, msg})
  end

  def handle_msg(pid, msg) when is_pid(pid) and is_binary(msg) do
    GenServer.cast(pid, {:handle_msg, msg})
  end

  @doc """
  Handle an incoming `message` that needs to be sent to all other registred clients
  """
  def handle_message(message, state) do
    case Messages.decode(message) do
      {:chat_message, data} ->
        %{user: user, content: content} = data

        Logger.info(
          "client #{inspect(state.id)} as #{user} sent message: #{
            inspect(content)
          }"
        )

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:update_player_position, _data} ->
        Logger.info("got an update player position message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:update_player_status, _data} ->
        Logger.info("got an update player status message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:create_room, _data} ->
        Logger.info("Created room")

        Room.start_link(state.id)

      {:start_room, _data} ->
        Logger.info("Started room")

      # Room.start()

      {:join_room, data} ->
        Logger.info("User join room")

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
  def handle_cast({:handle_msg, msg}, %{buffer: buffer} = state) do
    buffer = handle_buffer(buffer <> msg, state)
    {:noreply, %{state | buffer: buffer}}
  end

  @doc """
  Broadcast a message `msg`
  """
  def handle_cast({:broadcast_msg, msg}, state) do
    Logger.info("client #{inspect(state.id)} broadcasted a message.")

    ClientRegistry.get_entries()
    |> Stream.reject(fn {id, _pid} -> id == state.id end)
    |> Enum.each(fn {_id, pid} -> send_msg(pid, msg) end)

    {:noreply, state}
  end

  @doc """
  Send a message `msg` to the client of this worker
  """
  def handle_cast({:send_msg, msg}, state) do
    message = <<byte_size(msg)::little-unsigned-32>> <> msg
    state.transport.send(state.socket, message)
    {:noreply, state}
  end

  @doc """
  Unregister a client from the ClientRegistry
  """
  def handle_cast(:unregister, state) do
    ClientRegistry.unregister(state.id)
    Logger.info("client #{state.id} unregistered.")
    {:noreply, state}
  end

  @doc """
  Returns the current `state` of the worker
  """
  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end
end
