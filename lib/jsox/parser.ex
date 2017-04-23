defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  alias Jsox.SyntaxError

  @type json :: map | list | String.t | integer | float | true | false | nil

  @digits '0123456789'
  @minus_sign ?-
  @full_stop ?.
  @exps 'eE'
  @exp ?e
  #@digit_1_to_9 '123456789'
  #@whitespace '\s\r\t'
  #@new_line '\n'

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(iodata) do
    {:ok, parse(:json, iodata, 1, 0)}
  end

  defp parse(:json, <<char>> <> iodata, line, column)
    when char == @minus_sign or char in @digits,
    do: parse(:number, iodata, line, column + 1, [char])

  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:number, iodata, line, column + 1, [char|chars])
  defp parse(:number, <<@full_stop>> <> _iodata, line, column, [@minus_sign]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:number, <<@full_stop>> <> iodata, line, column, chars),
    do: parse(:float, iodata, line, column + 1, [@full_stop|chars])
  defp parse(:number, <<char>> <> _iodata, line, column, [@minus_sign])
    when char in @exps,
    do: raise SyntaxError, line: line, column: column
  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @exps,
    do: parse(:exponential, iodata, line, column + 1, [@exp|['.0'|chars]])
  defp parse(:number, _iodata, line, column, [@minus_sign]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:number, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_integer

  defp parse(:exponential, <<@minus_sign>> <> iodata, line, column, [@exp|_] = chars),
    do: parse(:exponential, iodata, line, column + 1, [@minus_sign|chars])
  defp parse(:exponential, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:exponential, iodata, line, column + 1, [char|chars])
  defp parse(:exponential, _iodata, line, column, [@exp|_]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:exponential, _iodata, line, column, [@minus_sign|_]),
    do: raise SyntaxError, line: line, column: column
  defp parse(:exponential, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

  defp parse(:float, <<char>> <> _iodata, line, column, [@full_stop|_])
    when char in @exps,
    do: raise SyntaxError, line: line, column: column
  defp parse(:float, <<char>> <> iodata, line, column, chars)
    when char in @exps,
    do: parse(:exponential, iodata, line, column + 1, [@exp|chars])
  defp parse(:float, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:float, iodata, line, column + 1, [char|chars])
  defp parse(:float, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

end
