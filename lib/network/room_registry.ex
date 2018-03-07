defmodule Network.RoomRegistry do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, Map.new(), name: __MODULE__)
  end

  def init(default) do
    {:ok, default}
  end

  @doc """
  Register a room using an unique `id` and his `pid`
  """
  def register({id, pid}) when is_pid(pid) do
    GenServer.call(__MODULE__, {:register, {id, pid}})
  end

  @doc """
  Unregister a room using his unique `id`
  """
  def unregister(id) do
    GenServer.call(__MODULE__, {:unregister, id})
  end

  @doc """
  Get the list of all registred rooms
  """
  def get_entries do
    GenServer.call(__MODULE__, :get_entries)
  end

  @doc """
  Function handling a room who wants to register
  """
  def handle_call({:register, {id, pid}}, _from, state) do
    {:reply, :ok, Map.put(state, id, pid)}
  end

  @doc """
  Function handling a room who wants to unregister
  """
  def handle_call({:unregister, id}, _from, state) do
    {:reply, :ok, Map.delete(state, id)}
  end

  @doc """
  Function returning the current state, which contains the list of all registred rooms
  """
  def handle_call(:get_entries, _from, state) do
    {:reply, state, state}
  end
end
