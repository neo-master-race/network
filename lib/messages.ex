defmodule Messages do
  @moduledoc """
  Encode and decode messages specified in the `messages.proto` file.
  """
  use Protobuf, from: Path.expand("../messages.proto", __DIR__)

  def decode(data) do
    %{msg: msg} = __MODULE__.Message.decode(data)
    msg
  rescue
    _ -> {:error, data}
  end

  def encode(data) do
    __MODULE__.Message.encode(data)
  end
end
