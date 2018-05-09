defmodule Network.Room do
  @moduledoc """
  Describe the state of a room.
  """

  use GenServer

  alias Messages.Message
  alias Messages.Player
  alias Messages.RoomListItem
  alias Messages.StartRoom

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
      max_players: max_players
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

  def broadcast(state, msg) do
    Enum.each(state.players, fn p ->
      GenServer.cast(p.pid, {:send_msg, msg})
    end)
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
      players: players
    )
  end

  @doc """
  Function handling a room who starts
  """
  def handle_cast(:start, state) do
    {:noreply, %{state | started: true}}
  end

  def handle_cast({:add_player, player}, state) do
    players =
      case length(Map.keys(state.players)) < state.max_players do
        false ->
          state.players

        true ->
          %{id: player_id} = player
          Map.put(state.players, player_id, player)
      end

    # start the game
    if length(Map.keys(players)) >= state.max_players do
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
