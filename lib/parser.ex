defmodule Parser do
  defstruct request: "",
            header: {},
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

    dbg(msg)

    %__MODULE__{}
    |> Map.put(:request, str)
    |> Map.put(:header, parse_header(header))
    |> Map.put(:arguments, parse_data(msg))
  end

  def parse_header(<<char, number>>) do
    {<<char>>, String.to_integer(<<number>>)}
  end

  def parse_data(data) do
    data
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {a, b} end)
  end
end
