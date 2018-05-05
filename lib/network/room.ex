defmodule Network.Room do
  @moduledoc """
  Describe the state of a room.
  """

  use GenServer

  @doc """
  Initialize a room
  """
  def start_link(creator_id) do
    default_state = %{
      id: UUID.uuid4(),
      # right on the room's modif
      creator: creator_id,
      players: %{},
      started: false
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
    %{id: player_id} = player
    players = Map.put(state.players, player_id, player)
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
end
