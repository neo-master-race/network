defmodule Messages.MessageTest do
  use ExUnit.Case
  alias Messages.Message
  alias Messages.ChatMessage
  alias Messages.Vector
  alias Messages.UpdatePlayerPosition

  doctest Messages.Message
  doctest Messages.ChatMessage
  doctest Messages.Vector
  doctest Messages.UpdatePlayerPosition

  test "create a message" do
    msg = Message.new(type: "empty")
    encodedMsg = Message.encode(msg)
    decodedMsg = Message.decode(encodedMsg)
    %{type: type} = decodedMsg
    assert type == "empty"
  end

  test "create a chat message" do
    msg = ChatMessage.new(content: "This is a test.", user: "TEST")
    encodedMsg = ChatMessage.encode(msg)
    decodedMsg = ChatMessage.decode(encodedMsg)
    %{content: content, user: user} = decodedMsg
    assert content == "This is a test."
    assert user == "TEST"
  end

  test "create a vector message" do
    msg = Vector.new(x: 1, y: 2, z: 3)
    encodedMsg = Vector.encode(msg)
    decodedMsg = Vector.decode(encodedMsg)
    %{x: x, y: y, z: z} = decodedMsg
    assert x == 1
    assert y == 2
    assert z == 3
  end

  test "create a update_player_position message" do
    vec = Vector.new(x: 1, y: 2, z: 3)
    msg = UpdatePlayerPosition.new(position: vec, direction: vec, scale: vec, user: "test")
    encodedMsg = UpdatePlayerPosition.encode(msg)
    decodedMsg = UpdatePlayerPosition.decode(encodedMsg)
    %{position: p, direction: d, scale: s, user: u} = decodedMsg
    assert p == vec
    assert d == vec
    assert s == vec
    assert u == "test"
  end
end
