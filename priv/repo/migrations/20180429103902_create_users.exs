defmodule Network.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add(:username, :string, size: 100)
      add(:password, :string)
    end

    alter table("users") do
      add(:race, :integer, default: 0)
      add(:victory, :integer, default: 0)
      add(:recordt1, :string, default: "--:--:--")
      add(:recordt2, :string, default: "--:--:--")
      add(:recordt3, :string, default: "--:--:--")
      # Cars 1
      add(:car1red, :integer, default: 0)
      add(:car1green, :integer, default: 0)
      add(:car1blue, :integer, default: 0)
      # Cars 2
      add(:car2red, :integer, default: 0)
      add(:car2green, :integer, default: 0)
      add(:car2blue, :integer, default: 0)
      # Cars 3
      add(:car3red, :integer, default: 0)
      add(:car3green, :integer, default: 0)
      add(:car3blue, :integer, default: 0)
      # Cars 4
      add(:car4red, :integer, default: 0)
      add(:car4green, :integer, default: 0)
      add(:car4blue, :integer, default: 0)
      # Cars 1
      add(:car1slider, :float, default: 0)
      add(:car1redTR, :integer, default: 0)
      add(:car1greenTR, :integer, default: 0)
      add(:car1blueTR, :integer, default: 0)
      add(:car1cursorX, :float, default: 0)
      add(:car1cursorY, :float, default: 0)
      # Cars 2
      add(:car2slider, :float, default: 0)
      add(:car2redTR, :integer, default: 0)
      add(:car2greenTR, :integer, default: 0)
      add(:car2blueTR, :integer, default: 0)
      add(:car2cursorX, :float, default: 0)
      add(:car2cursorY, :float, default: 0)
      # Cars 3
      add(:car3slider, :float, default: 0)
      add(:car3redTR, :integer, default: 0)
      add(:car3greenTR, :integer, default: 0)
      add(:car3blueTR, :integer, default: 0)
      add(:car3cursorX, :float, default: 0)
      add(:car3cursorY, :float, default: 0)
      # Cars 4
      add(:car4slider, :float, default: 0)
      add(:car4redTR, :integer, default: 0)
      add(:car4greenTR, :integer, default: 0)
      add(:car4blueTR, :integer, default: 0)
      add(:car4cursorX, :float, default: 0)
      add(:car4cursorY, :float, default: 0)
    end

    create unique_index :users, [:username], username: :users_username_unique
  end
end
