defmodule Network.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username)
    field(:password)

    field(:race, :integer)
    field(:victory, :integer)
    field(:recordt1, :string)
    field(:recordt2, :string)
    field(:recordt3, :string)
    # Cars 1
    field(:car1red, :integer)
    field(:car1green, :integer)
    field(:car1blue, :integer)
    # Cars 2
    field(:car2red, :integer)
    field(:car2green, :integer)
    field(:car2blue, :integer)
    # Cars 3
    field(:car3red, :integer)
    field(:car3green, :integer)
    field(:car3blue, :integer)
    # Cars 4
    field(:car4red, :integer)
    field(:car4green, :integer)
    field(:car4blue, :integer)
    # Cars 1
    field(:car1slider, :float)
    field(:car1redTR, :integer)
    field(:car1greenTR, :integer)
    field(:car1blueTR, :integer)
    field(:car1cursorX, :float)
    field(:car1cursorY, :float)
    # Cars 2
    field(:car2slider, :float)
    field(:car2redTR, :integer)
    field(:car2greenTR, :integer)
    field(:car2blueTR, :integer)
    field(:car2cursorX, :float)
    field(:car2cursorY, :float)
    # Cars 3
    field(:car3slider, :float)
    field(:car3redTR, :integer)
    field(:car3greenTR, :integer)
    field(:car3blueTR, :integer)
    field(:car3cursorX, :float)
    field(:car3cursorY, :float)
    # Cars 4
    field(:car4slider, :float)
    field(:car4redTR, :integer)
    field(:car4greenTR, :integer)
    field(:car4blueTR, :integer)
    field(:car4cursorX, :float)
    field(:car4cursorY, :float)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :username,
      :password,
      :race,
      :victory,
      :recordt1,
      :recordt2,
      :recordt3,
      :car1red,
      :car1green,
      :car1blue,
      :car2red,
      :car2green,
      :car2blue,
      :car3red,
      :car3green,
      :car3blue,
      :car4red,
      :car4green,
      :car4blue,
      :car1slider,
      :car1redTR,
      :car1greenTR,
      :car1blueTR,
      :car1cursorX,
      :car1cursorY,
      :car2slider,
      :car2redTR,
      :car2greenTR,
      :car2blueTR,
      :car2cursorX,
      :car2cursorY,
      :car3slider,
      :car3redTR,
      :car3greenTR,
      :car3blueTR,
      :car3cursorX,
      :car3cursorY,
      :car4slider,
      :car4redTR,
      :car4greenTR,
      :car4blueTR,
      :car4cursorX,
      :car4cursorY
    ])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
