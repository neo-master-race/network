defmodule Messages.MessageTest do
  use ExUnit.Case
  alias Messages.Message
  alias Messages.ChatMessage
  alias Messages.Vector
  alias Messages.UpdatePlayerPosition

  doctest Messages
  doctest Messages.Message
  doctest Messages.ChatMessage
  doctest Messages.Vector
  doctest Messages.UpdatePlayerPosition

  test "create a message (with errors check)" do
    chat_msg = ChatMessage.new(content: "This is a test.", user: "TEST")
    msg = Message.new(type: "chat_message", msg: {:chat_message, chat_msg})
    encoded_msg = Messages.encode(msg)
    decoded_msg = Messages.decode(encoded_msg)
    {:chat_message, %{content: content, user: user}} = decoded_msg
    assert content == "This is a test."
    assert user == "TEST"
  end

  test "create a message" do
    msg = Message.new(type: "empty")
    encoded_msg = Message.encode(msg)
    decoded_msg = Message.decode(encoded_msg)
    %{type: type} = decoded_msg
    assert type == "empty"
  end

  test "create a chat message" do
    msg = ChatMessage.new(content: "This is a test.", user: "TEST")
    encoded_msg = ChatMessage.encode(msg)
    decoded_msg = ChatMessage.decode(encoded_msg)
    %{content: content, user: user} = decoded_msg
    assert content == "This is a test."
    assert user == "TEST"
  end

  test "create a vector message" do
    msg = Vector.new(x: 1, y: 2, z: 3)
    encoded_msg = Vector.encode(msg)
    decoded_msg = Vector.decode(encoded_msg)
    %{x: x, y: y, z: z} = decoded_msg
    assert x == 1
    assert y == 2
    assert z == 3
  end

  test "create a update_player_position message" do
    vec = Vector.new(x: 1, y: 2, z: 3)

    msg =
      UpdatePlayerPosition.new(
        position: vec,
        direction: vec,
        scale: vec,
        user: "test"
      )

    encoded_msg = UpdatePlayerPosition.encode(msg)
    decoded_msg = UpdatePlayerPosition.decode(encoded_msg)
    %{position: p, direction: d, scale: s, user: u} = decoded_msg
    assert p == vec
    assert d == vec
    assert s == vec
    assert u == "test"
  end
end
