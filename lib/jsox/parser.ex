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
    {:ok, parse(:json, iodata, 0)}
  catch
    {token, pos} -> {:error, token, pos}
  end

  defp parse(:json, <<char>> <> iodata, pos)
    when char == @minus_sign or char in @digits,
    do: parse(:number, iodata, pos + 1, [char])
  defp parse(:json, <<@quotation_mark>> <> iodata, pos),
    do: parse(:string, iodata, pos + 1, [])

  defp parse(:number, <<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse(:number, iodata, pos + 1, [char|chars])
  defp parse(:number, <<@full_stop>> <> _iodata, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp parse(:number, <<@full_stop>> <> iodata, pos, chars),
    do: parse(:float, iodata, pos + 1, [@full_stop|chars])
  defp parse(:number, <<char>> <> _iodata, pos, [@minus_sign])
    when char in @exps,
    do: throw {:number, pos}
  defp parse(:number, <<char>> <> iodata, pos, chars)
    when char in @exps,
    do: parse(:exponential, iodata, pos + 1, [@exp|['.0'|chars]])
  defp parse(:number, _iodata, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp parse(:number, _iodata, _pos, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_integer

  defp parse(:exponential, <<@minus_sign>> <> iodata, pos, [@exp|_] = chars),
    do: parse(:exponential, iodata, pos + 1, [@minus_sign|chars])
  defp parse(:exponential, <<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse(:exponential, iodata, pos + 1, [char|chars])
  defp parse(:exponential, _iodata, pos, [@exp|_]),
    do: throw {:exponential, pos}
  defp parse(:exponential, _iodata, pos, [@minus_sign|_]),
    do: throw {:exponential, pos}
  defp parse(:exponential, _iodata, _pos, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

  defp parse(:float, <<char>> <> _iodata, pos, [@full_stop|_])
    when char in @exps,
    do: throw {:float, pos}
  defp parse(:float, <<char>> <> iodata, pos, chars)
    when char in @exps,
    do: parse(:exponential, iodata, pos + 1, [@exp|chars])
  defp parse(:float, <<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse(:float, iodata, pos + 1, [char|chars])
  defp parse(:float, _iodata, _pos, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float

  defp parse(:string, <<@quotation_mark>> <> _iodata, _pos, chars),
    do: chars
        |> Enum.reverse
        |> IO.iodata_to_binary
  defp parse(:string, <<@escape, @solidus>> <> iodata, pos, chars),
    do: parse(:string, iodata, pos + 2, [@solidus|chars])
  defp parse(:string, <<@escape, char>> <> iodata, pos, chars)
    when char in @escape_chars,
    do: parse(:string, iodata, pos + 2, [Map.get(@escapes, char)|chars])
  defp parse(:string,
             <<@escape, @unicode, a1, b1, c1, d1, @escape, @unicode, a2, b2, c2, d2>> <> iodata,
             pos, chars)
    when a1 in @surrogate_a and a2 in @surrogate_a and b1 in @surrogate_b1 and b2 in @surrogate_b2 do
    hi = List.to_integer([a1, b1, c1, d1], 16)
    lo = List.to_integer([a2, b2, c2, d2], 16)
    codepoint = 0x10000 + ((hi &&& 0x03FF) <<< 10) + (lo &&& 0x03FF)
    parse(:string, iodata, pos + 11, [<<codepoint :: utf8>>|chars])
  end
  defp parse(:string, <<@escape, @unicode, seq :: binary-size(4)>> <> iodata, pos, chars),
    do: parse(:string, iodata, pos + 6, [<<String.to_integer(seq, 16) :: utf8>>|chars])
  defp parse(:string, <<@escape>> <> _iodata, pos, _chars),
    do: throw {:string, pos}
  defp parse(:string, <<char>> <> iodata, pos, chars),
    do: parse(:string, iodata, pos, [char|chars])

end
