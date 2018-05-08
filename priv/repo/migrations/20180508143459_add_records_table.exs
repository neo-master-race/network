defmodule Network.Repo.Migrations.AddRecordsTable do
  use Ecto.Migration

  def change do
    create table("records") do
      add(:id_player, references("users"))
      add(:id_circuit, :int)
      add(:record, :string)
      constraint("records", :threeCircuits, check: "id_circuit BETWEEN 1 AND 3")
    end
  end
end
