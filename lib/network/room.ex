defmodule Network.Room do
  @moduledoc """
  Describe the state of a room.
  """

  use GenServer

  alias Messages.RoomListItem
  alias Messages.Player

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

  @doc """
  Function handling a room who starts
  """
  def handle_cast(:start, state) do
    {:noreply, %{state | started: true}}
  end

  def handle_cast({:add_player, player}, state) do
    if length(Map.keys(state.players)) < state.max_players do
      %{id: player_id} = player
      players = Map.put(state.players, player_id, player)
      {:noreply, %{state | players: players}}
      # else
    end
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
    players =
      Enum.map(state.players, fn {_pk, pv} ->
        Player.new(
          username: pv.username,
          nb_races: pv.nb_races,
          nb_wins: pv.nb_wins,
          record: pv.record
        )
      end)

    room =
      RoomListItem.new(
        id: state.id,
        room_type: state.room_type,
        id_circuit: state.id_circuit,
        max_players: state.max_players,
        nb_players: Kernel.map_size(state.players),
        players: players
      )

    {:reply, room, state}
  end
end
