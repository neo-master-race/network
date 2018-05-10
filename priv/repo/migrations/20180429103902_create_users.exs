defmodule Network.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add(:username, :string)
      add(:password, :string)
    end

    alter table("users") do
      add(:race, :int)
      add(:victory, :int)
      add(:recordt1, :string)
      add(:recordt2, :string)
      add(:recordt3, :string)
      # Cars 1
      add(:car1red, :int)
      add(:car1green, :int)
      add(:car1blue, :int)
      # Cars 2
      add(:car2red, :int)
      add(:car2green, :int)
      add(:car2blue, :int)
      # Cars 3
      add(:car3red, :int)
      add(:car3green, :int)
      add(:car3blue, :int)
      # Cars 4
      add(:car4red, :int)
      add(:car4green, :int)
      add(:car4blue, :int)
      # Cars 1
      add(:car1slider, :float)
      add(:car1redTR, :int)
      add(:car1greenTR, :int)
      add(:car1blueTR, :int)
      add(:car1cursorX, :float)
      add(:car1cursorY, :float)
      # Cars 2
      add(:car2slider, :float)
      add(:car2redTR, :int)
      add(:car2greenTR, :int)
      add(:car2blueTR, :int)
      add(:car2cursorX, :float)
      add(:car2cursorY, :float)
      # Cars 3
      add(:car3slider, :float)
      add(:car3redTR, :int)
      add(:car3greenTR, :int)
      add(:car3blueTR, :int)
      add(:car3cursorX, :float)
      add(:car3cursorY, :float)
      # Cars 4
      add(:car4slider, :float)
      add(:car4redTR, :int)
      add(:car4greenTR, :int)
      add(:car4blueTR, :int)
      add(:car4cursorX, :float)
      add(:car4cursorY, :float)
    end
  end
end
