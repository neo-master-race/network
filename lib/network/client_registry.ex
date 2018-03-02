defmodule Network.ClientRegistry do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, Map.new(), name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end
end
