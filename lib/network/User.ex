defmodule Network.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username)
    field(:password)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end
end
