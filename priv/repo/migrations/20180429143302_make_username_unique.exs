defmodule Network.Repo.Migrations.MakeUsernameUnique do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :username, :string, size: 100
    end

    create unique_index :users, [:username], username: :users_username_unique
  end
end
