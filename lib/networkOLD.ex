require Logger

defmodule NetworkOLD do
  @moduledoc """
  Manage TCP sockets
  """

  @doc """
  Initializing the network part (listening on a specific port)
  """
  def accept(port) do
    {:ok, clients} = Agent.start_link(fn -> [] end)

    case :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true]) do
      {:ok, socket} ->
        Logger.info("accepting connections on port #{port}")
        loop_acceptor(socket, clients)

      {:error, :eaddrinuse} ->
        Logger.error("something is already listening on port #{port}.")

      _ ->
        Logger.error("unknown error")
    end
  end

  defp loop_acceptor(socket, clients) do
    {:ok, client} = :gen_tcp.accept(socket)
    clientId = Port.info(client)[:id]
    Logger.info("client #{clientId} joined!")

    write_info(client, "successfully connected to the server!")
    Agent.update(clients, fn list -> [client] ++ list end)

    {:ok, pid} =
      Task.Supervisor.start_child(Network.TaskSupervisor, fn -> serve(client, clients) end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, clients)
  end

  defp serve(socket, clients) do
    clientId = Port.info(socket)[:id]

    case read_line(socket) do
      {:ok, data} ->
        content = data.content
        Logger.info("client #{clientId} sent message: #{content}")

        Agent.get(clients, fn list ->
          Enum.each(list, fn c -> write_line(c, content) end)
        end)

        serve(socket, clients)

      {:warn, msg} ->
        Logger.warn(msg)

        serve(socket, clients)

      {:logout, reason} ->
        Agent.update(clients, fn list -> list -- [socket] end)
        Logger.info("client #{clientId} has leaved. Reason: #{reason}")

      {:error, msg} ->
        Logger.error(msg)
    end
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        case Messages.decode(data) do
          {:ok, data} -> {:ok, data}
          _ -> {:warn, "cannot decode message: #{String.trim(data)}"}
        end

      {:error, :closed} ->
        {:logout, "socket is closed"}

      _ ->
        {:error, "unknown error"}
    end
  end

  defp write_line(socket, line) do
    newMsg = Messages.Message.new(content: line)

    case Messages.encode(newMsg) do
      {:ok, encodedMsg} ->
        :gen_tcp.send(socket, encodedMsg)

      _ ->
        Logger.warn("cannot encode and send message: #{String.trim(line)}")
    end
  end

  defp write_info(socket, line) do
    write_line(socket, "[INFO] #{line}\n")
  end
end
