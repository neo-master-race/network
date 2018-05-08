defmodule Network.Worker do
  import Ecto.Query, only: [from: 2]
  use GenServer
  require Logger

  alias Network.ClientRegistry
  alias Network.Repo
  alias Network.Room
  alias Network.RoomRegistry
  alias Network.User
  alias Messages.Disconnect
  alias Messages.JoinRoomResponse
  alias Messages.LoginResponse
  alias Messages.Message
  alias Messages.RegisterResponse
  alias Messages.RoomListResponse

  def start_link(socket, transport, id) do
    default_state = %{
      socket: socket,
      transport: transport,
      id: id,
      client_name: "",
      buffer: "",
      current_room: nil,
      registred_user: false,
      database_id: 0
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

  def add_me_as_room_player(room_pid, state) do
    GenServer.cast(
      room_pid,
      {:add_player,
       %{
         id: state.id,
         username: state.client_name,
         nb_races: 256,
         nb_wins: 242,
         record: "00:42:42"
       }}
    )
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

      {:update_player_position, data} ->
        Logger.info("got an update player position message.")
        %{user: user} = data

        cond do
          user == state.client_name ->
            # do not send to the sender
            ClientRegistry.get_entries()
            |> Stream.reject(fn {id, _pid} -> id == state.id end)
            |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

          state.client_name == "" ->
            GenServer.cast(
              self(),
              {:set_client_name, user}
            )

            # do not send to the sender
            ClientRegistry.get_entries()
            |> Stream.reject(fn {id, _pid} -> id == state.id end)
            |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

          true ->
            Logger.warn(
              'permissions error when trying to handle #{inspect(data)}.'
            )
        end

      {:update_player_status, data} ->
        Logger.info("got an update player status message.")
        %{user: user} = data

        cond do
          user == state.client_name ->
            # do not send to the sender
            ClientRegistry.get_entries()
            |> Stream.reject(fn {id, _pid} -> id == state.id end)
            |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

          state.client_name == "" ->
            GenServer.cast(
              self(),
              {:set_client_name, user}
            )

            # do not send to the sender
            ClientRegistry.get_entries()
            |> Stream.reject(fn {id, _pid} -> id == state.id end)
            |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)
        end

      {:update_player_status_request, _data} ->
        Logger.info("got an update player status request message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:starting_position, _data} ->
        Logger.info("got a staring position message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:disconnect, _data} ->
        Logger.info("got a disconnect message.")

        # do not send to the sender
        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)

      {:create_room, data} ->
        Logger.info("Request for creating a room.")

        %{
          room_type: room_type,
          id_circuit: id_circuit,
          max_players: max_players
        } = data

        # creator
        {:ok, pid} =
          Room.start_link(state.id, room_type, id_circuit, max_players)

        add_me_as_room_player(pid, state)

        room_infos = GenServer.call(pid, :get_entries)
        %{id: room_id} = room_infos

        room = GenServer.call(pid, :get_item)

        message_to_send =
          Messages.encode(
            Message.new(
              type: "room_list_response",
              msg:
                {:room_list_response, RoomListResponse.new(room_list: [room])}
            )
          )

        GenServer.cast(
          self(),
          {:send_msg, message_to_send}
        )

        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message_to_send) end)

        GenServer.cast(self(), {:set_current_room, pid})
        RoomRegistry.register({room_id, pid})
        Logger.info("Room #{inspect(pid)} created")

        GenServer.cast(
          self(),
          {:send_msg,
           Messages.encode(
             Message.new(
               type: "join_room_response",
               msg: {
                 {:join_room_response,
                  JoinRoomResponse.new(
                    success: true,
                    room: room
                  )}
               }
             )
           )}
        )

      {:start_room, data} ->
        Logger.info("Started room")

        %{id: room_id} = data
        %{^room_id => room_pid} = RoomRegistry.get_entries()
        GenServer.cast(room_pid, :start)

        Logger.info(inspect(RoomRegistry.get_entries()))
        Logger.info(inspect(GenServer.call(room_pid, :get_entries)))

      {:join_room_request, data} ->
        %{id: room_id} = data
        Logger.info("#{state.client_name} asked to join room ##{room_id}")
        %{^room_id => room_pid} = RoomRegistry.get_entries()
        add_me_as_room_player(room_pid, state)
        GenServer.cast(self(), {:set_current_room, room_pid})
        room = GenServer.call(room_pid, :get_item)

        message_to_send =
          Messages.encode(
            Message.new(
              type: "room_list_response",
              msg:
                {:room_list_response, RoomListResponse.new(room_list: [room])}
            )
          )

        GenServer.cast(
          self(),
          {:send_msg, message_to_send}
        )

        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message_to_send) end)

        GenServer.cast(
          self(),
          {:send_msg,
           Messages.encode(
             Message.new(
               type: "join_room_response",
               msg: {
                 {:join_room_response,
                  JoinRoomResponse.new(
                    success: true,
                    room: room
                  )}
               }
             )
           )}
        )

      {:login_request, data} ->
        %{username: username, password: password} = data
        Logger.info("#{username} tried to log in")

        query =
          from(
            u in "users",
            where: u.username == ^username,
            select: u.password
          )

        res = Repo.all(query)
        success = length(res) > 0

        success =
          case success do
            true ->
              pass = List.first(res)
              Bcrypt.verify_pass(password, pass)

            _ ->
              false
          end

        if success do
          GenServer.cast(self(), {:set_registred_user, username})
        end

        GenServer.cast(
          self(),
          {:send_msg,
           Messages.encode(
             Message.new(
               type: "login_response",
               msg:
                 {:login_response,
                  LoginResponse.new(success: success, username: username)}
             )
           )}
        )

      {:register_request, data} ->
        %{username: username, password: password} = data
        Logger.info("#{username} tried to register")

        u =
          User.changeset(%Network.User{}, %{
            username: username,
            password: Bcrypt.hash_pwd_salt(password)
          })

        {status, _data} = Repo.insert(u)
        success = status == :ok

        if success do
          GenServer.cast(self(), {:set_registred_user, username})
        end

        GenServer.cast(
          self(),
          {:send_msg,
           Messages.encode(
             Message.new(
               type: "register_response",
               msg:
                 {:register_response,
                  RegisterResponse.new(success: success, username: username)}
             )
           )}
        )

      {:room_list_request, _data} ->
        Logger.info("#{state.client_name} asked for room list")

        rooms = RoomRegistry.get_entries()

        rooms =
          Enum.map(rooms, fn {_k, v} ->
            GenServer.call(v, :get_item)
          end)

        message_to_send =
          Messages.encode(
            Message.new(
              type: "room_list_response",
              msg: {:room_list_response, RoomListResponse.new(room_list: rooms)}
            )
          )

        GenServer.cast(
          self(),
          {:send_msg, message_to_send}
        )

        ClientRegistry.get_entries()
        |> Stream.reject(fn {id, _pid} -> id == state.id end)
        |> Enum.each(fn {_id, pid} -> send_msg(pid, message_to_send) end)

      {:change_username, data} ->
        %{username: username} = data
        Logger.info("client ##{state.id} is now knows as #{username}")

        GenServer.cast(
          self(),
          {:set_client_name, username}
        )

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
  Setter for registred user
  """
  def handle_cast({:set_registred_user, user}, state) do
    {:noreply, %{state | registred_user: true, client_name: user}}
  end

  @doc """
  Setter for unregistred user (for loggin out)
  """
  def handle_cast(:set_unregistred_user, state) do
    {:noreply, %{state | registred_user: false, client_name: ""}}
  end

  @doc """
  Setter for client name
  """
  def handle_cast({:set_client_name, user}, state) do
    {:noreply, %{state | client_name: user}}
  end

  @doc """
  Setter for current room
  """
  def handle_cast({:set_current_room, pid}, state) do
    {:noreply, %{state | current_room: pid}}
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
    Logger.info("client #{state.id} (#{state.client_name}) unregistered.")

    GenServer.cast(
      self(),
      {:broadcast_msg,
       Messages.encode(
         Message.new(
           type: "disconnect",
           msg: {:disconnect, Disconnect.new(user: state.client_name)}
         )
       )}
    )

    ClientRegistry.unregister(state.id)
    {:noreply, state}
  end

  @doc """
  Returns the current `state` of the worker
  """
  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end
end
