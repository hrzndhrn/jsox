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
  @whitespace '\s\r\t\n'
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

  defp json(<<char>> <> data, pos) do
    pos = pos + 1
    cond do
      char in @whitespace -> json(data, pos)
      char == @quotation_mark -> string(data, pos, [])
      char == @left_square_bracket -> list(data, pos, [])
      char == @left_curly_bracket-> map(data, pos, [])
      char == @minus_sign or char in @digits -> number(data, pos, [char])
      char == ?t -> _true(data, pos)
      char == ?f -> _false(data, pos)
      char == ?n -> _null(data, pos)
      true -> throw {:json, pos}
    end
  end

  defp _true(<<"rue">> <> data, pos), do: {true, data, pos + 3}
  defp _true(_data, pos), do: throw {:true, pos}

  defp _false(<<"alse">> <> data, pos), do: {false, data, pos + 4}
  defp _false(_data, pos), do: throw {:false, pos}

  defp _null(<<"ull">> <> data, pos), do: {nil, data, pos + 3}
  defp _null(_data, pos), do: throw {:null, pos}

  defp key(<<char>> <> data, pos) do
    pos = pos + 1
    cond do
      char in @whitespace -> key(data, pos)
      char == @quotation_mark -> string(data, pos, [])
      true -> throw {:key, pos}
    end
  end

  defp number(<<char>> <> data, pos, chars)
    when char in @digits,
    do: number(data, pos + 1, [char|chars])
  defp number(<<@full_stop>> <> _data, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp number(<<@full_stop>> <> data, pos, chars),
    do: float(data, pos + 1, [@full_stop|chars])
  defp number(<<char>> <> _data, pos, [@minus_sign])
    when char in @exps,
    do: throw {:number, pos}
  defp number(<<char>> <> data, pos, chars)
    when char in @exps,
    do: exponential(data, pos + 1, [@exp|['.0'|chars]])
  defp number(_data, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp number(data, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
             |> String.to_integer
    {result, data, pos}
  end

  defp exponential(<<@minus_sign>> <> data, pos, [@exp|_] = chars),
    do: exponential(data, pos + 1, [@minus_sign|chars])
  defp exponential(<<char>> <> data, pos, chars)
    when char in @digits,
    do: exponential(data, pos + 1, [char|chars])
  defp exponential(_data, pos, [@exp|_]),
    do: throw {:exponential, pos}
  defp exponential(_data, pos, [@minus_sign|_]),
    do: throw {:exponential, pos}
  defp exponential(data, pos, chars) do
    result = chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float
    {result, data, pos}
  end

  defp float(<<char>> <> _data, pos, [@full_stop|_])
    when char in @exps,
    do: throw {:float, pos}
  defp float(<<char>> <> data, pos, chars)
    when char in @exps,
    do: exponential(data, pos + 1, [@exp|chars])
  defp float(<<char>> <> data, pos, chars)
    when char in @digits,
    do: float(data, pos + 1, [char|chars])
  defp float(data, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
             |> String.to_float
    {result, data, pos}
  end

  defp string(<<@quotation_mark>> <> data, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
    {result, data, pos}
  end
  defp string(<<@escape, @solidus>> <> data, pos, chars),
    do: string(data, pos + 2, [@solidus|chars])
  defp string(<<@escape, char>> <> data, pos, chars)
    when char in @escape_chars,
    do: string(data, pos + 2, [Map.get(@escapes, char)|chars])
  defp string(
             <<@escape, @unicode, a1, b1, c1, d1, @escape, @unicode, a2, b2, c2, d2>> <> data,
             pos, chars)
    when a1 in @surrogate_a and a2 in @surrogate_a and b1 in @surrogate_b1 and b2 in @surrogate_b2 do
    hi = List.to_integer([a1, b1, c1, d1], 16)
    lo = List.to_integer([a2, b2, c2, d2], 16)
    codepoint = 0x10000 + ((hi &&& 0x03FF) <<< 10) + (lo &&& 0x03FF)
    string(data, pos + 11, [<<codepoint :: utf8>>|chars])
  end
  defp string(<<@escape, @unicode, seq :: binary-size(4)>> <> data, pos, chars),
    do: string(data, pos + 6, [<<String.to_integer(seq, 16) :: utf8>>|chars])
  defp string(<<@escape>> <> _data, pos, _chars),
    do: throw {:string, pos}
  defp string(<<char>> <> data, pos, chars),
    do: string(data, pos + 1, [char|chars])

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
