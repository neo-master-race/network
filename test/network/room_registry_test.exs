defmodule Network.RoomRegistryTest do
  use ExUnit.Case
  alias Network.RoomRegistry

  doctest Network.RoomRegistry

  test "register a room" do
    room_id = :rand.uniform(241_485)

    :ok = RoomRegistry.register({room_id, self()})
    entries = RoomRegistry.get_entries()
    assert Map.has_key?(entries, room_id)
  end

  test "unregister a room" do
    room_id = :rand.uniform(65_535)

    :ok = RoomRegistry.register({room_id, self()})
    entries = RoomRegistry.get_entries()
    assert Map.has_key?(entries, room_id)

    :ok = RoomRegistry.unregister(room_id)
    entries = RoomRegistry.get_entries()
    assert not Map.has_key?(entries, room_id)
  end

  test "unregister an unregistred room" do
    room_id = :rand.uniform(65_535)
    entries = RoomRegistry.get_entries()
    assert not Map.has_key?(entries, room_id)
    :ok = RoomRegistry.unregister(room_id)
  end
end
