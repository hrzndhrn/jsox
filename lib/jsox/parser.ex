defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  use Bitwise

  @type json :: map | list | String.t | integer | float | true | false | nil

  @digits '0123456789'
  @whitespace '\s\r\t\n'
  @minus_sign ?-
  @full_stop ?.
  @exps 'eE'
  @quotation_mark ?"
  @escape ?\\
  @escapes %{
    ?\\ => '\\',
    ?" => '\"',
    ?n => '\n',
    ?r => '\r',
    ?b => '\b',
    ?f => '\f',
    ?t => '\t',
    ?/ => '\/'
  }
  @escape_chars [?u|Map.keys(@escapes)]
  @surrogate_a 'dD'
  @surrogate_b1 '89abAb'
  @surrogate_b2 'cedfCDEF'
  @left_square_bracket ?[
  @right_square_bracket ?]
  @left_curly_bracket ?{
  @right_curly_bracket ?}
  @colon ?:
  @comma ?,

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(data) do
    {result, data, pos} = json(data, 0)
    if data =~ ~r/^\s*$/ do
      {:ok, result}
    else
      {:error, :eof, pos}
    end
  catch
    {token, pos} -> {:error, token, pos}
  end

  defp json(<<char>> <> data, pos)
    when char in @whitespace,
    do: json(data, pos + 1)
  defp json(<<char>> <> data, pos)
    when char == @quotation_mark,
    do: string(data, pos + 1, [])
  defp json(<<char>> <> data, pos)
    when char == @left_square_bracket,
    do: list(data, pos + 1, [])
  defp json(<<char>> <> data, pos)
    when char == @left_curly_bracket,
    do: map(data, pos + 1, [])
  defp json(<<char>> <> data, pos)
    when char in '-0123456789',
    do: number(data, pos + 1, [char], (if char == ?-, do: :minus, else: :digit))
  defp json(<<"true">> <> data, pos),
    do: {true, data, pos + 4}
  defp json(<<"false">> <> data, pos),
    do: {false, data, pos + 5}
  defp json(<<"null">> <> data, pos),
    do: {nil, data, pos + 4}
  defp json(_data, pos),
    do: throw {:json, pos + 1}

  defp key(<<char>> <> data, pos)
    when char in @whitespace,
    do: key(data, pos + 1)
  defp key(<<char>> <> data, pos)
    when char == @quotation_mark,
    do: string(data, pos + 1, [])
  defp key(_data, pos),
    do: throw {:key, pos}

  defp number(<<char>> <> data, pos, chars, _last)
    when char in @digits,
    do: number(data, pos + 1, [chars,char], :digit)
  defp number(<<@full_stop>> <> _data, pos, _chars, :minus),
    do: throw {:number, pos + 1}
  defp number(<<@full_stop>> <> data, pos, chars, _last),
    do: float(data, pos + 1, [chars, @full_stop], :full_stop)
  defp number(<<char>> <> _data, pos, _chars, :minus)
    when char in @exps,
    do: throw {:number, pos}
  defp number(<<char>> <> data, pos, chars, _last)
    when char in @exps,
    do: exponential(data, pos + 1, [chars, '.0e'], :exp)
  defp number(_data, pos, _chars, :minus),
    do: throw {:number, pos}
  defp number(data, pos, chars, _last) do
    result = chars
             |> IO.iodata_to_binary
             |> String.to_integer
    {result, data, pos}
  end

  defp exponential(<<@minus_sign>> <> data, pos, chars, :exp),
    do: exponential(data, pos + 1, [chars, @minus_sign], :minus)
  defp exponential(<<char>> <> data, pos, chars, _last)
    when char in @digits,
    do: exponential(data, pos + 1, [chars, char], :digit)
  defp exponential(_data, pos, _chars, :exp),
    do: throw {:exponential, pos}
  defp exponential(_data, pos, _chars, :minus),
    do: throw {:exponential, pos}
  defp exponential(data, pos, chars, _last),
    do: {chars |> IO.iodata_to_binary |> String.to_float, data, pos}

  defp float(<<char>> <> _data, pos, _chars, :full_stop)
    when char in @exps,
    do: throw {:float, pos}
  defp float(<<char>> <> data, pos, chars, _last)
    when char in @exps,
    do: exponential(data, pos + 1, [chars, 'e'], :exp)
  defp float(<<char>> <> data, pos, chars, _last)
    when char in @digits,
    do: float(data, pos + 1, [chars, char], :digit)
  defp float(data, pos, chars, _last),
    do: {chars |> IO.iodata_to_binary |> String.to_float, data, pos}

  defp string(<<@quotation_mark>> <> data, pos, chars),
    do: {chars |> Enum.reverse |> IO.iodata_to_binary, data, pos}
  defp string(<<?\\, char>> <> data, pos, chars) when char in @escape_chars do
    cond do
      char == ?u -> unicode(data, pos + 1, chars)
      true -> string(data, pos + 2, [Map.get(@escapes, char)|chars])
    end
  end
  defp string(<<@escape>> <> _data, pos, _chars),
    do: throw {:string, pos}
  defp string(<<char>> <> data, pos, chars),
    do: string(data, pos + 1, [char|chars])

  defp unicode(<<a1, b1, c1, d1, ?\\, ?u, a2, b2, c2, d2>> <> data, pos, chars)
    when a1 in @surrogate_a and a2 in @surrogate_a and b1 in @surrogate_b1 and b2 in @surrogate_b2 do
    hi = List.to_integer([a1, b1, c1, d1], 16)
    lo = List.to_integer([a2, b2, c2, d2], 16)
    codepoint = 0x10000 + ((hi &&& 0x03FF) <<< 10) + (lo &&& 0x03FF)
    string(data, pos + 11, [<<codepoint :: utf8>>|chars])
  end
  defp unicode(<<seq :: binary-size(4)>> <> data, pos, chars),
    do: string(data, pos + 6, [<<String.to_integer(seq, 16) :: utf8>>|chars])

  defp list(<<char>> <> data, pos, list)
    when char in @whitespace,
    do: list(data, pos + 1, list)
  defp list(<<@right_square_bracket>> <> data, pos, list),
    do: {Enum.reverse(list), data, pos + 1}
  defp list(<<@comma>> <> _data, pos, []),
    do: throw {:list, pos}
  defp list(<<@comma>> <> data, pos, list) do
    {result, data, pos} = json(data, pos + 1)
    list(data, pos, [result|list])
  end
  defp list(data, pos, []) do
    {result, data, pos} = json(data, pos)
    list(data, pos, [result])
  end
  defp list(_data, pos, _list),
    do: throw{:list, pos}

  defp map(<<char>> <> data, pos, list)
    when char in @whitespace,
    do: map(data,  pos + 1, list)
  defp map(<<@right_curly_bracket>> <> data, pos, list) do
    result = for [value, key] <- Enum.chunk(list, 2), into: %{}, do: {key, value}
    {result, data, pos + 1}
  end
  defp map(<<@comma>> <> _data, pos, []),
    do: throw {:map, pos + 1}
  defp map(<<@comma>> <> data, pos, list) do
    {result, data, pos} = key(data, pos + 1)
    map(data, pos + 1, [result|list])
  end
  defp map(<<@colon>> <> _data, pos, []),
    do: throw {:map, pos + 1}
  defp map(<<@colon>> <> data, pos, list) do
    {result, data, pos} = json(data, pos + 1)
    map(data, pos + 1, [result|list])
  end
  defp map(data, pos, []) do
    {result, data, pos} = key(data, pos)
    map(data, pos, [result])
  end
  defp map(_data, pos, _list),
    do: throw {:map, pos + 1}

end
