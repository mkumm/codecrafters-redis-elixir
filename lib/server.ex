defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application
  alias Storage

  def start(_type, _args) do
    Storage.start_link(%{})
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

  def server(:no_client), do: nil

  def serve(client) do
    client
    |> recv()
    |> send_response(client)

    serve(client)
  end

  defp recv(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        Parser.nparser(data)

      {:error, :closed} ->
        :gen_tcp.close(client)
        :no_client
    end
  end

  defp send_response(:no_client, _client), do: :no_client

  defp send_response(%Parser{command: "PING"} = _parser, client) do
    :gen_tcp.send(client, "+PONG\r\n")
  end

  defp send_response(%Parser{command: "ECHO"} = parser, client) do
    [{_, msg}] = parser.arguments
    :gen_tcp.send(client, "+#{msg}\r\n")
  end

  defp send_response(%Parser{command: "SET"} = parser, client) do
    dbg(parser)
    expirey = Keyword.get(parser.arguments, :px)
    # Storage.add_data(%{key => {value, set_expiration(expirey)}})
    :gen_tcp.send(client, "+OK\r\n")
  end

  defp send_response(%Parser{command: "GET"} = parser, client) do
    [{_, msg}] = parser.arguments
    {value, expires} = Storage.get_key(msg)

    if value and !expired?(expires) do
      :gen_tcp.send(client, "+#{value}\r\n")
    else
      :gen_tcp.send(client, "$-1\r\n")
    end
  end

  defp set_expiration(nil), do: nil

  defp set_expiration(ms) do
    DateTime.utc_now()
    |> DateTime.add(String.to_integer(ms), :millisecond)
    |> dbg()
  end

  defp expired?(time) do
    case DateTime.compare(time, DateTime.utc_now()) do
      :lt -> true
      _ -> false
    end
  end
end
