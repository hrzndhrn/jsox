defmodule Jsox do
  @moduledoc """
  Documentation for Jsox.
  """

  alias Jsox.Parser

  @spec parse(iodata) :: {:ok, Parser.json} | {:error, String.t}
  def parse(iodata),
    do: iodata
        |> IO.iodata_to_binary
        |> Parser.parse

  @spec parse!(iodata) :: Parser.json
  def parse!(iodata) do
    case parse(iodata) do
      {:ok, value} -> value
      {:error, msg} -> raise msg
    end
  end

end
