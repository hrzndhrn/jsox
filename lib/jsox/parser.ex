defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  @type json :: map | list | String.t | integer | float | true | false | nil

  @digits '0123456789'
  @minus_sigun ?-
  #@digit_1_to_9 '123456789'
  #@whitespace '\s\r\t'
  #@new_line '\n'

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(iodata) do
    {:ok, parse(:start, iodata, 0, 0)}
  end

  defp parse(:start, <<char>> <> iodata, line, column)
    when char == @minus_sigun or char in @digits,
    do: parse(:number, iodata, line, column + 1, [char])

  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:number, iodata, line, column + 1, [char|chars])
  defp parse(:number, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_integer


end
