defmodule Network.TrackRecords do
  use Ecto.Schema
  import Ecto.Changeset

  schema "track_records" do
    field(:record)
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [
      :id,
      :record
    ])
    |> validate_required([:id, :record])
  end
end
