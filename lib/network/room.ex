defmodule Network.Room do
  @moduledoc """
  Describe the state of a room.
  """

  use GenServer

  alias Messages.Message
  alias Messages.Player
  alias Messages.RoomListItem
  alias Messages.StartRoom
  alias Network.RoomRegistry

  @doc """
  Initialize a room
  """
  def start_link(creator_id, room_type, id_circuit, max_players) do
    default_state = %{
      id: UUID.uuid4(),
      # right on the room's modif
      creator: creator_id,
      players: %{},
      started: false,
      room_type: room_type,
      id_circuit: id_circuit,
      max_players: max_players,
      starting_positions: Enum.shuffle(Enum.to_list(1..max_players))
    }

    GenServer.start_link(__MODULE__, default_state)
  end

  def init(default) do
    {:ok, default}
  end

  @doc """
  Start the current room
  """
  def start(pid) do
    GenServer.call(__MODULE__, {:start, pid})
  end

  @doc """
  Ends the current room
  """
  def finish do
    GenServer.call(__MODULE__, :finish)
  end

  @doc """
  Get the details of the current room
  """
  def get_entries do
    GenServer.call(__MODULE__, :get_entries)
  end

  def broadcast(%{players: players}, msg) do
    for {_, %{pid: pid}} <- players do
      GenServer.cast(pid, {:send_msg, msg})
    end
  end

  @doc """
  Returns this room as a RoomListItem
  """
  def generate_room_list_item(state) do
    players =
      Enum.map(state.players, fn {_pk, pv} ->
        Player.new(
          username: pv.username,
          nb_races: pv.nb_races,
          nb_wins: pv.nb_wins,
          record: pv.record
        )
      end)

    RoomListItem.new(
      id: state.id,
      room_type: state.room_type,
      id_circuit: state.id_circuit,
      max_players: state.max_players,
      nb_players: Kernel.map_size(state.players),
      players: players,
      starting_positions: state.starting_positions
    )
  end

  @doc """
  Function handling a room who starts
  """
  def handle_cast(:start, state) do
    {:noreply, %{state | started: true}}
  end

  def handle_cast({:broadcast, message}, state) do
    broadcast(state, message)
    {:noreply, state}
  end

  def handle_cast(
        {:broadcast, message, except_pid},
        %{players: players} = state
      ) do
    for {_, %{pid: pid}} <- players do
      if pid != except_pid do
        GenServer.cast(pid, {:send_msg, message})
      end
    end

    {:noreply, state}
  end

  def handle_cast({:add_player, player}, %{players: players} = state) do
    players =
      if Enum.count(players) < state.max_players do
        record =
          case state.id_circuit do
            1 -> player.record1
            2 -> player.record2
            3 -> player.record3
            _ -> player.record
          end

        player = %{player | record: record}
        Map.put(players, player.id, player)
      else
        players
      end

    state = %{state | players: players}

    # start the game
    if Enum.count(players) >= state.max_players do
      room = generate_room_list_item(state)

      msg =
        Messages.encode(
          Message.new(
            type: "start_room",
            msg: {:start_room, StartRoom.new(success: true, room: room)}
          )
        )

      broadcast(state, msg)
    end

    {:noreply, state}
  end

  def handle_cast({:remove_player, player_id}, %{players: players} = state) do
    players = Map.delete(players, player_id)

    if map_size(players) <= 0 do
      RoomRegistry.unregister(state.id)
    end

    {:noreply, %{state | players: players}}
  end

  @doc """
  Function handling a room who ends
  """
  def handle_call(:finish, _from, state) do
    {:reply, :ok, %{state | started: false}}
  end

  @doc """
  Function returning the current state, which contains the details of the current room
  """
  def handle_call(:get_entries, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Returns item as a RoomListItem
  """
  def handle_call(:get_item, _from, state) do
    room = generate_room_list_item(state)
    {:reply, room, state}
  end
end
