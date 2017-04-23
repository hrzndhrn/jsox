defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  alias Jsox.SyntaxError

  @type json :: map | list | String.t | integer | float | true | false | nil

  @digits '0123456789'
  @minus_sigun ?-
  @full_stop ?.
  #@digit_1_to_9 '123456789'
  #@whitespace '\s\r\t'
  #@new_line '\n'

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(iodata) do
    {:ok, parse(:start, iodata, 1, 0)}
  end

  defp parse(:start, <<char>> <> iodata, line, column)
    when char == @minus_sigun or char in @digits,
    do: parse(:number, iodata, line, column + 1, [char])

  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:number, iodata, line, column + 1, [char|chars])
  defp parse(:number, <<@full_stop>> <> _iodata, line, column, [@minus_sigun]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:number, <<@full_stop>> <> iodata, line, column, chars),
    do: parse(:float, iodata, line, column + 1, [@full_stop|chars])
  defp parse(:number, _iodata, line, column, [@minus_sigun]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:number, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_integer

  defp parse(:float, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:float, iodata, line, column + 1, [char|chars])
  defp parse(:float, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

end
