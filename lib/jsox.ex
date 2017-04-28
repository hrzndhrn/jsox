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
      {:error, token, pos} -> raise SyntaxError,
                                      token: token,
                                      iodata: iodata,
                                      line: 1,
                                      pos: pos
    end
  end

end
