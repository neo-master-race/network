defmodule Network.Room do
  @moduledoc """
  Describe the state of a room.
  """

  use GenServer

  @doc """
  Initialize a room
  """
  def create_room(id_creator) do
    room = %{
      id: UUID.uuid4(),
      # right on the room's modif
      creator: id_creator,
      players: %{},
      started: false
    }
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
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
end
