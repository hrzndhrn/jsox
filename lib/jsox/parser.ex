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
  def parse(iodata) do
    {result, iodata, pos} = parse_json(iodata, 0)
    if iodata =~ ~r/^\s*$/ do
      {:ok, result}
    else
      {:error, :eof, pos}
    end
  catch
    {token, pos} -> {:error, token, pos}
  end

  defp parse_json(<<char>> <> iodata, pos) do
    pos = pos + 1
    cond do
      char in @whitespace -> parse_json(iodata, pos)
      char == @quotation_mark -> parse_string(iodata, pos, [])
      char == @left_square_bracket -> parse_list(iodata, pos, [])
      char == @left_curly_bracket-> parse_map(iodata, pos, [])
      char == @minus_sign or char in @digits -> parse_number(iodata, pos, [char])
      char == ?t -> parse_true(iodata, pos)
      char == ?f -> parse_false(iodata, pos)
      char == ?n -> parse_null(iodata, pos)
      true -> throw {:json, pos}
    end
  end

  defp parse_true(<<"rue">> <> iodata, pos), do: {true, iodata, pos + 3}
  defp parse_true(_iodata, pos), do: throw {:true, pos}

  defp parse_false(<<"alse">> <> iodata, pos), do: {false, iodata, pos + 4}
  defp parse_false(_iodata, pos), do: throw {:false, pos}

  defp parse_null(<<"ull">> <> iodata, pos), do: {nil, iodata, pos + 3}
  defp parse_null(_iodata, pos), do: throw {:null, pos}

  defp parse_key(<<char>> <> iodata, pos) do
    pos = pos + 1
    cond do
      char in @whitespace -> parse_key(iodata, pos)
      char == @quotation_mark -> parse_string(iodata, pos, [])
      true -> throw {:key, pos}
    end
  end

  defp parse_number(<<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse_number(iodata, pos + 1, [char|chars])
  defp parse_number(<<@full_stop>> <> _iodata, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp parse_number(<<@full_stop>> <> iodata, pos, chars),
    do: parse_float(iodata, pos + 1, [@full_stop|chars])
  defp parse_number(<<char>> <> _iodata, pos, [@minus_sign])
    when char in @exps,
    do: throw {:number, pos}
  defp parse_number(<<char>> <> iodata, pos, chars)
    when char in @exps,
    do: parse_exponential(iodata, pos + 1, [@exp|['.0'|chars]])
  defp parse_number(_iodata, pos, [@minus_sign]),
    do: throw {:number, pos}
  defp parse_number(iodata, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
             |> String.to_integer
    {result, iodata, pos}
  end

  defp parse_exponential(<<@minus_sign>> <> iodata, pos, [@exp|_] = chars),
    do: parse_exponential(iodata, pos + 1, [@minus_sign|chars])
  defp parse_exponential(<<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse_exponential(iodata, pos + 1, [char|chars])
  defp parse_exponential(_iodata, pos, [@exp|_]),
    do: throw {:exponential, pos}
  defp parse_exponential(_iodata, pos, [@minus_sign|_]),
    do: throw {:exponential, pos}
  defp parse_exponential(iodata, pos, chars) do
    result = chars
        |> Enum.reverse
        |> IO.iodata_to_binary
        |> String.to_float
    {result, iodata, pos}
  end

  defp parse_float(<<char>> <> _iodata, pos, [@full_stop|_])
    when char in @exps,
    do: throw {:float, pos}
  defp parse_float(<<char>> <> iodata, pos, chars)
    when char in @exps,
    do: parse_exponential(iodata, pos + 1, [@exp|chars])
  defp parse_float(<<char>> <> iodata, pos, chars)
    when char in @digits,
    do: parse_float(iodata, pos + 1, [char|chars])
  defp parse_float(iodata, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
             |> String.to_float
    {result, iodata, pos}
  end

  defp parse_string(<<@quotation_mark>> <> iodata, pos, chars) do
    result = chars
             |> Enum.reverse
             |> IO.iodata_to_binary
    {result, iodata, pos}
  end
  defp parse_string(<<@escape, @solidus>> <> iodata, pos, chars),
    do: parse_string(iodata, pos + 2, [@solidus|chars])
  defp parse_string(<<@escape, char>> <> iodata, pos, chars)
    when char in @escape_chars,
    do: parse_string(iodata, pos + 2, [Map.get(@escapes, char)|chars])
  defp parse_string(
             <<@escape, @unicode, a1, b1, c1, d1, @escape, @unicode, a2, b2, c2, d2>> <> iodata,
             pos, chars)
    when a1 in @surrogate_a and a2 in @surrogate_a and b1 in @surrogate_b1 and b2 in @surrogate_b2 do
    hi = List.to_integer([a1, b1, c1, d1], 16)
    lo = List.to_integer([a2, b2, c2, d2], 16)
    codepoint = 0x10000 + ((hi &&& 0x03FF) <<< 10) + (lo &&& 0x03FF)
    parse_string(iodata, pos + 11, [<<codepoint :: utf8>>|chars])
  end
  defp parse_string(<<@escape, @unicode, seq :: binary-size(4)>> <> iodata, pos, chars),
    do: parse_string(iodata, pos + 6, [<<String.to_integer(seq, 16) :: utf8>>|chars])
  defp parse_string(<<@escape>> <> _iodata, pos, _chars),
    do: throw {:string, pos}
  defp parse_string(<<char>> <> iodata, pos, chars),
    do: parse_string(iodata, pos + 1, [char|chars])

  defp parse_list(<<char>> <> iodata, pos, list)
    when char in @whitespace,
    do: parse_list(iodata, pos + 1, list)
  defp parse_list(<<@right_square_bracket>> <> iodata, pos, list),
    do: {Enum.reverse(list), iodata, pos + 1}
  defp parse_list(<<@comma>> <> _iodata, pos, []),
    do: throw {:list, pos}
  defp parse_list(<<@comma>> <> iodata, pos, list) do
    {result, iodata, pos} = parse_json(iodata, pos + 1)
    parse_list(iodata, pos, [result|list])
  end
  defp parse_list(iodata, pos, []) do
    {result, iodata, pos} = parse_json(iodata, pos)
    parse_list(iodata, pos, [result])
  end
  defp parse_list(_iodata, pos, _list),
    do: throw{:list, pos}

  defp parse_map(<<char>> <> iodata, pos, list)
    when char in @whitespace,
    do: parse_map(iodata,  pos + 1, list)
  defp parse_map(<<@right_curly_bracket>> <> iodata, pos, list) do
    result = for [value, key] <- Enum.chunk(list, 2), into: %{}, do: {key, value}
    {result, iodata, pos + 1}
  end
  defp parse_map(<<@comma>> <> _iodata, pos, []),
    do: throw {:map, pos + 1}
  defp parse_map(<<@comma>> <> iodata, pos, list) do
    {result, iodata, pos} = parse_key(iodata, pos + 1)
    parse_map(iodata, pos + 1, [result|list])
  end
  defp parse_map(<<@colon>> <> _iodata, pos, []),
    do: throw {:map, pos + 1}
  defp parse_map(<<@colon>> <> iodata, pos, list) do
    {result, iodata, pos} = parse_json(iodata, pos + 1)
    parse_map(iodata, pos + 1, [result|list])
  end
  defp parse_map(iodata, pos, []) do
    {result, iodata, pos} = parse_key(iodata, pos)
    parse_map(iodata, pos, [result])
  end
  defp parse_map(_iodata, pos, _list),
    do: throw {:map, pos + 1}

end
