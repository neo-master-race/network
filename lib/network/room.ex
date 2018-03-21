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

    GenServer.start_link(__MODULE__, default_state, name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end

  @doc """
  Start the current room
  """
  def start(id) do
    GenServer.call(__MODULE__, :start)
  end

  @doc """
  Function handling a room who starts
  """
  def handle_call(:start, _from, state) do
    {:reply, :ok, %{state | started: true}}
  end

  @doc """
  Ends the current room
  """
  def finish(id) do
    GenServer.call(__MODULE__, :finish)
  end

  @doc """
  Function handling a room who ends
  """
  def handle_call(:finish, _from, state) do
    {:reply, :ok, %{state | started: false}}
  end

  @doc """
  Get the details of the current room
  """
  def get_entries do
    GenServer.call(__MODULE__, :get_entries)
  end

  @doc """
  Function returning the current state, which contains the details of the current room 
  """
  def handle_call(:get_entries, _from, state) do
    {:reply, state, state}
  end
end
