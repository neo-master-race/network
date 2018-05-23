defmodule Network.Worker do
  import(Ecto.Query, only: [from: 2])
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
  alias Messages.UserStats

  def start_link(socket, transport, id) do
    default_state = %{
      socket: socket,
      transport: transport,
      id: id,
      client_name: "",
      buffer: "",
      current_room: nil,
      registred_user: false,
      user_stats: init_user_stats()
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
         pid: self(),
         username: state.client_name,
         nb_races: state.user_stats.race,
         nb_wins: state.user_stats.victory,
         record: state.user_stats.recordt1,
         record1: state.user_stats.recordt1,
         record2: state.user_stats.recordt2,
         record3: state.user_stats.recordt3
       }}
    )
  end

  def init_user_stats() do
    %UserStats{
      username: "",
      race: 0,
      victory: 0,
      recordt1: "--:--:--",
      recordt2: "--:--:--",
      recordt3: "--:--:--",
      car1red: 0,
      car1green: 0,
      car1blue: 0,
      car2red: 0,
      car2green: 0,
      car2blue: 0,
      car3red: 0,
      car3green: 0,
      car3blue: 0,
      car4red: 0,
      car4green: 0,
      car4blue: 0,
      car1slider: 0,
      car1redTR: 0,
      car1greenTR: 0,
      car1blueTR: 0,
      car1cursorX: 0,
      car1cursorY: 0,
      car2slider: 0,
      car2redTR: 0,
      car2greenTR: 0,
      car2blueTR: 0,
      car2cursorX: 0,
      car2cursorY: 0,
      car3slider: 0,
      car3redTR: 0,
      car3greenTR: 0,
      car3blueTR: 0,
      car3cursorX: 0,
      car3cursorY: 0,
      car4slider: 0,
      car4redTR: 0,
      car4greenTR: 0,
      car4blueTR: 0,
      car4cursorX: 0,
      car4cursorY: 0
    }
  end

  def broadcast_room(message, state) do
    if state.current_room != nil && is_pid(state.current_room) do
      GenServer.cast(state.current_room, {:broadcast, message, self()})
    end
  end

  def broadcast_all(message, state) do
    # do not send to the sender
    ClientRegistry.get_entries()
    |> Stream.reject(fn {id, _pid} -> id == state.id end)
    |> Enum.each(fn {_id, pid} -> send_msg(pid, message) end)
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

        broadcast_all(message, state)
        state

      {:update_player_position, _data} ->
        Logger.info("got an update player position message.")

        broadcast_room(message, state)
        state

      {:update_player_status, _data} ->
        Logger.info("got an update player status message.")
        broadcast_room(message, state)
        state

      {:update_player_status_request, _data} ->
        Logger.info("got an update player status request message.")

        broadcast_room(message, state)
        state

      {:starting_position, _data} ->
        Logger.info("got a staring position message.")

        broadcast_room(message, state)
        state

      {:disconnect, _data} ->
        Logger.info("got a disconnect message.")

        broadcast_all(message, state)
        state

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

        broadcast_all(message_to_send, state)

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
                 :join_room_response,
                 JoinRoomResponse.new(
                   success: true,
                   room: room
                 )
               }
             )
           )}
        )

        state

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

        broadcast_all(message_to_send, state)

        GenServer.cast(
          self(),
          {:send_msg,
           Messages.encode(
             Message.new(
               type: "join_room_response",
               msg: {
                 :join_room_response,
                 JoinRoomResponse.new(
                   success: true,
                   room: room
                 )
               }
             )
           )}
        )

        state

      {:login_request, data} ->
        %{username: username, password: password} = data
        Logger.info("#{username} tried to log in")

        state = %{state | user_stats: update_user_stats(username, state)}

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
                  LoginResponse.new(
                    success: success,
                    username: username,
                    user_stats: state.user_stats
                  )}
             )
           )}
        )

        state

      {:register_request, data} ->
        %{username: username, password: password} = data
        Logger.info("#{username} tried to register")

        state = %{state | user_stats: update_user_stats(username, state)}

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
                  RegisterResponse.new(
                    success: success,
                    username: username,
                    user_stats: state.user_stats
                  )}
             )
           )}
        )

        state

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

        broadcast_all(message_to_send, state)
        state

      {:change_username, data} ->
        %{username: username} = data
        Logger.info("client ##{state.id} is now knows as #{username}")

        user_stats = %{state.user_stats | username: username}

        state = %{
          state
          | registred_user: true,
            client_name: username,
            user_stats: user_stats
        }

        state

      {:set_user_stats, %{user_stats: us} = _data} ->
        %{username: username} = us
        Logger.info("client ##{state.id} aka #{username} updated his stats")

        Repo.get_by(User, username: username)
        |> Ecto.Changeset.change(Map.from_struct(us))
        |> Repo.update()

        %{state | user_stats: us}

      {:leave_room, _data} ->
        if state.current_room != nil && is_pid(state.current_room) do
          GenServer.cast(state.current_room, {:remove_player, state.id})
        end

        %{state | current_room: nil}

      _ ->
        Logger.warn("cannot decode message: #{String.trim(message)}")
        state
    end
  end

  @doc """
  Handling the `buffer` when getting some datas.

  Useful when many messages are coming at the same time, or if messages are too long.
  """
  def handle_buffer(%{buffer: buffer} = state) do
    case buffer do
      <<len::little-unsigned-32, message::binary-size(len)>> <> rest ->
        state = handle_message(message, state)
        handle_buffer(%{state | buffer: rest})

      _ ->
        state
    end
  end

  def update_user_stats(user, state) do
    if user == "" do
      init_user_stats()
    else
      query =
        from(
          u in "users",
          where: u.username == ^user,
          select: u.id
        )

      res = Repo.all(query)

      if length(res) > 0 do
        id = List.first(res)
        struct(UserStats, Map.from_struct(Repo.get!(User, id)))
      else
        state.user_stats
      end
    end
  end

  @doc """
  Setter for registred user
  """
  def handle_cast({:set_registred_user, user}, state) do
    user_stats = %{state.user_stats | username: user}

    {:noreply,
     %{state | registred_user: true, client_name: user, user_stats: user_stats}}
  end

  @doc """
  Setter for unregistred user (for loggin out)
  """
  def handle_cast(:set_unregistred_user, state) do
    user_stats = %{state.user_stats | username: ""}

    {:noreply,
     %{state | registred_user: false, client_name: "", user_stats: user_stats}}
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
    state = handle_buffer(%{state | buffer: buffer <> msg})
    {:noreply, state}
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

    if state.current_room != nil && is_pid(state.current_room) do
      GenServer.cast(state.current_room, {:remove_player, state.id})
    end

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
