defmodule Network.Room do
  use GenServer

  @doc """
  Initialize a room
  """
  def create_room(id_creator) do
    room = %{
      id: UUID.uuid4(),
      creator: id_creator, #right on the room's modif
      players: %{},
      started: false,
      position: nil
    }
  end
end
