defmodule Messages do
  use Protobuf, from: Path.expand("../messages.proto", __DIR__)

  def decode(data) do
    try do
      {:ok, __MODULE__.Message.decode(data)}
    rescue
      _ -> {:error, data}
    end
  end

  def encode(data) do
    __MODULE__.Message.encode(data)
  end
end
