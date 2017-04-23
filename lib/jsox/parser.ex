defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  use Bitwise

  @type json :: map | list | String.t | integer | float | true | false | nil

  @digits '0123456789'
  @minus_sign ?-
  @full_stop ?.
  @exps 'eE'
  @exp ?e
  @quotation_mark ?"
  @escape ?\\
  @escapes %{
    ?\\ => '\\',
    ?" => '\"',
    ?n => '\n',
    ?r => '\r',
    ?b => '\b',
    ?f => '\f',
    ?t => '\t'
  }
  @escape_chars Map.keys(@escapes)
  @solidus ?/
  @unicode ?u
  # @newline '\n'
  #@digit_1_to_9 '123456789'
  #@whitespace '\s\r\t'

  @surrogate_a 'dD'
  @surrogate_b1 '89abAb'
  @surrogate_b2 'cedfCDEF'

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(iodata) do
    try do
      {:ok, parse(:json, iodata, 1, 0)}
    catch
      error -> error
    end
  end

  defp parse(:json, <<char>> <> iodata, line, column)
    when char == @minus_sign or char in @digits,
    do: parse(:number, iodata, line, column + 1, [char])
  defp parse(:json, <<@quotation_mark>> <> iodata, line, column),
    do: parse(:string, iodata, line, column + 1, [])

  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @digits,
    do: parse(:number, iodata, line, column + 1, [char|chars])
  defp parse(:number, <<@full_stop>> <> _iodata, _line, column, [@minus_sign]),
    do: throw {:error, :number, column}
  defp parse(:number, <<@full_stop>> <> iodata, line, column, chars),
    do: parse(:float, iodata, line, column + 1, [@full_stop|chars])
  defp parse(:number, <<char>> <> _iodata, _line, column, [@minus_sign])
    when char in @exps,
    do: throw {:error, :number, column}
  defp parse(:number, <<char>> <> iodata, line, column, chars)
    when char in @exps,
    do: parse(:exponential, iodata, line, column + 1, [@exp|['.0'|chars]])
  defp parse(:number, _iodata, _line, column, [@minus_sign]),
    do: throw {:error, :number, column}
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
  defp parse(:exponential, _iodata, _line, column, [@exp|_]),
    do: throw {:error, :exponential, column}
  defp parse(:exponential, _iodata, _line, column, [@minus_sign|_]),
    do: throw {:error, :exponential, column}
  defp parse(:exponential, _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

  defp parse(:float, <<char>> <> _iodata, _line, column, [@full_stop|_])
    when char in @exps,
    do: throw {:error, :float, column}
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

  defp parse(:string, <<@quotation_mark>> <> _iodata, _line, _column, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
  defp parse(:string, <<@escape, @solidus>> <> iodata, line, column, chars),
    do: parse(:string, iodata, line, column + 2, [@solidus|chars])
  defp parse(:string, <<@escape, char>> <> iodata, line, column, chars)
    when char in @escape_chars,
    do: parse(:string, iodata, line, column + 2, [Map.get(@escapes, char)|chars])
  defp parse(:string,
             <<@escape, @unicode, a1, b1, c1, d1, @escape, @unicode, a2, b2, c2, d2>> <> iodata,
             line, column, chars)
    when a1 in @surrogate_a and a2 in @surrogate_a and b1 in @surrogate_b1 and b2 in @surrogate_b2 do
    hi = List.to_integer([a1, b1, c1, d1], 16)
    lo = List.to_integer([a2, b2, c2, d2], 16)
    codepoint = 0x10000 + ((hi &&& 0x03FF) <<< 10) + (lo &&& 0x03FF)
    parse(:string, iodata, line, column + 11, [<<codepoint :: utf8>>|chars])
  end
  defp parse(:string, <<@escape, @unicode, seq :: binary-size(4)>> <> iodata, line, column, chars),
    do: parse(:string, iodata, line, column + 6, [<<String.to_integer(seq, 16) :: utf8>>|chars])
  defp parse(:string, <<@escape>> <> _iodata, _line, column, _chars),
    do: throw {:error, :string, column}
  defp parse(:string, <<char>> <> iodata, line, column, chars),
    do: parse(:string, iodata, line, column, [char|chars])

end
