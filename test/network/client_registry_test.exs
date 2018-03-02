defmodule Network.ClientRegistryTest do
  use ExUnit.Case
  alias Network.ClientRegistry

  doctest Network.ClientRegistry

  test "register a client" do
    client_id = :rand.uniform(65535)

    :ok = ClientRegistry.register({client_id, self()})
    entries = ClientRegistry.get_entries()
    assert Map.has_key?(entries, client_id)
  end

  test "unregister a client" do
    client_id = :rand.uniform(65535)

    :ok = ClientRegistry.register({client_id, self()})
    entries = ClientRegistry.get_entries()
    assert Map.has_key?(entries, client_id)

    :ok = ClientRegistry.unregister(client_id)
    entries = ClientRegistry.get_entries()
    assert not Map.has_key?(entries, client_id)
  end

  test "unregister an unregistred client" do
    client_id = :rand.uniform(65535)
    entries = ClientRegistry.get_entries()
    assert not Map.has_key?(entries, client_id)
    :ok = ClientRegistry.unregister(client_id)
  end
end
