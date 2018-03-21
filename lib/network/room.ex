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

  def start(id) do
    GenServer.call(__MODULE__, :start)
  end

  def handle_call({:start, id}, _from, state) do
    {:reply, :ok, %{state | started: true}}
  end

  def handle_call(:get_entries, _from, state) do
    {:reply, state, state}
  end
end
