defmodule Jsox do
  @moduledoc """
  Documentation for Jsox.
  """

  alias Jsox.Parser
  alias Jsox.SyntaxError

  @spec parse(iodata) :: {:ok, Parser.json} | {:error, String.t}
  def parse(iodata),
    do: iodata
        |> IO.iodata_to_binary
        |> Parser.parse

  @spec parse!(iodata) :: Parser.json
  def parse!(iodata) do
    case parse(iodata) do
      {:ok, json} -> json
      {:error, _context, pos} -> raise SyntaxError, line: 1, column: pos
    end
  end

end
