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
    |> send_response(client)

    serve(client)
  end

  defp recv(client) do
    {:ok, data} = :gen_tcp.recv(client, 0)
    Parser.nparser(data)
    # data
  end

  defp send_response(%{arguments: [{_, "PING"}]}, client) do
    :gen_tcp.send(client, "+PONG\r\n")
  end

  defp send_response(%{arguments: [{_, "ECHO"}, {_, echo}]}, client) do
    :gen_tcp.send(client, "+#{echo}\r\n")
  end
end
