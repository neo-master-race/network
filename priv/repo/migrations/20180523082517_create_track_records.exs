defmodule Network.Repo.Migrations.CreateTrackRecords do
  use Ecto.Migration

  def change do
    create table("track_records") do
      add(:record, :string, size: 100, default: "--:--:--")
    end
  end
end
