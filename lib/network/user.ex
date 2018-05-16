defmodule Network.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username)
    field(:password)

    field(:race)
    field(:victory)
    field(:recordt1)
    field(:recordt2)
    field(:recordt3)
    # Cars 1
    field(:car1red)
    field(:car1green)
    field(:car1blue)
    # Cars 2
    field(:car2red)
    field(:car2green)
    field(:car2blue)
    # Cars 3
    field(:car3red)
    field(:car3green)
    field(:car3blue)
    # Cars 4
    field(:car4red)
    field(:car4green)
    field(:car4blue)
    # Cars 1
    field(:car1slider)
    field(:car1redTR)
    field(:car1greenTR)
    field(:car1blueTR)
    field(:car1cursorX)
    field(:car1cursorY)
    # Cars 2
    field(:car2slider)
    field(:car2redTR)
    field(:car2greenTR)
    field(:car2blueTR)
    field(:car2cursorX)
    field(:car2cursorY)
    # Cars 3
    field(:car3slider)
    field(:car3redTR)
    field(:car3greenTR)
    field(:car3blueTR)
    field(:car3cursorX)
    field(:car3cursorY)
    # Cars 4
    field(:car4slider)
    field(:car4redTR)
    field(:car4greenTR)
    field(:car4blueTR)
    field(:car4cursorX)
    field(:car4cursorY)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end
end
