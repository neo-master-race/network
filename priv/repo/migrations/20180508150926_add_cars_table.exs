defmodule Network.Repo.Migrations.AddCarsTable do
  use Ecto.Migration

  def change do
    create table("cars") do
      add(:id_player, references("users"))
      add(:r1, :int)
      add(:g1, :int)
      add(:b1, :int)
      add(:r2, :int)
      add(:g2, :int)
      add(:b2, :int)
      add(:r3, :int)
      add(:g3, :int)
      add(:b3, :int)
      add(:r4, :int)
      add(:g4, :int)
      add(:b4, :int)
    end
  end
end
