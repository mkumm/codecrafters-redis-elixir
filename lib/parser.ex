defmodule Parser do
  defstruct request: "",
            header: {},
            command: "",
            arguments: []

  def nparser(str) do
    str
    |> init()
  end

  def init(str) do
    [header | msg] =
      str
      |> String.trim()
      |> String.split("\r\n")

    %__MODULE__{}
    |> Map.put(:request, str)
    |> Map.put(:header, parse_header(header))
    |> Map.put(:command, set_command(msg))
    |> Map.put(:arguments, parse_arguments(msg))
  end

  def set_command([_, command | _]) do
    String.upcase(command)
  end

  def parse_header(<<char, number>>) do
    {<<char>>, String.to_integer(<<number>>)}
  end

  def parse_arguments([_, _ | data]) do
    data
    |> Enum.chunk_every(2)
    |> Enum.map(fn [_a, b] -> b end)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {String.to_atom(a), b} end)
    |> Keyword.new()
    |> dbg()
  end

  def parse_data(_), do: []
end
