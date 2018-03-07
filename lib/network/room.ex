defmodule Network.Room do
  use GenSever

  @doc """
  Initialize a room
  """
  def create_room(id_creator) do
    %Room{
      id: UUID.uuid4(),
      creator: id_creator, #right on the room's modif
      players: %{},
      started: false,
      position: nil
    }
  end

  def 

end
