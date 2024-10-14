defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  @doc """
  Listen for incoming connections
  """
  def listen() do
    IO.puts("Logs from your program will appear here!")

    {:ok, socket} = :gen_tcp.listen(6379, [:binary, active: false, reuseaddr: true])
    accept(socket)
  end

  @doc """
  Application pauses here waiting to accept a connection. 
  A new task/process will be created with each client 
  connection.
  """
  def accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.start_link(Server, :serve, [client])
    accept(socket)
  end

  def serve(client) do
    client
    |> recv()

    serve(client)
  end

  defp recv(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        IO.inspect(data)
        :gen_tcp.send(client, "+PONG\r\n")

      {:error, reason} ->
        :gen_tcp.close(client)
        {:error, reason}
    end
  end
end
