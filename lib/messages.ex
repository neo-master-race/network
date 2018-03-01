defmodule Messages do
  use Protobuf, from: Path.expand("../messages.proto", __DIR__)
end
