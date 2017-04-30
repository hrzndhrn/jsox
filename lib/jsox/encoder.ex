defmodule Jsox.Encoder do

  use Bitwise

  @escape_map %{
    ?\\ => '\\\\',
    ?\" => '\\"',
    ?\n => '\\n',
    ?\r => '\\r',
    ?\b => '\\b',
    ?\f => '\\f',
    ?\t => '\\t',
    ?\/ => '\\/' }

  def encode(value), do: {:ok, value |> _encode |> IO.iodata_to_binary}

  defp _encode(""), do: ~s("")
  defp _encode(true), do: ~s(true)
  defp _encode(false), do: ~s(false)
  defp _encode(nil), do: ~s(null)
  defp _encode(value) when is_integer(value), do: Integer.to_string(value)
  defp _encode(value) when is_float(value), do: Float.to_string(value)
  defp _encode(value) when is_binary(value), do: escape(value)
  defp _encode([]), do: ~s([])
  defp _encode(value) when is_list(value), do: [?[, list(value, []), ?]]
  defp _encode(value) when value == %{}, do: ~s({})
  defp _encode(value) when is_map(value), do: [?{, map(value), ?}]

  defp list([h], acc), do: Enum.reverse([_encode(h)|acc])
  defp list([h|t], acc), do: list(t, [[_encode(h), ?,]|acc])

  defp escape(value), do: [?", escape(value, []), ?"]
  defp escape("", chars), do: Enum.reverse(chars)
  for {char, seq} <- Map.to_list(@escape_map) do
    defp escape(<<unquote(char)>> <> data, chars) do
      escape(data, [unquote(seq)|chars])
    end
  end
  defp escape(<<char>> <> data, chars)
    when char <= 0x1F or char == 0x7F,
    do: escape(data, [unicode(char)|chars])
  defp escape(<<char :: utf8>> <> data, chars)
    when char in 0x80..0x9F,
    do: escape(data, [unicode(char)|chars])
  defp escape(<<char :: utf8>> <> data, chars)
    when char in 0xA0..0xFFFF,
    do: surrogate(data, [unicode(char)|chars])
  defp escape(<<char>> <> data, chars),
    do: escape(data, [char|chars])

  defp surrogate(<<char>> <> data, chars) when char > 0xFFFF do
    code = char - 0x10000
    [unicode(0xD800 ||| (code >>> 10)),
     unicode(0xDC00 ||| (code &&& 0x3FF))
     | escape(data, chars)]
  end
  defp surrogate(data, chars),
    do: escape(data, chars)

  defp unicode(char) do
    code = Integer.to_charlist(char, 16)
    case length(code) do
      1 -> ["\\u000", code]
      2 -> ["\\u00", code]
      3 -> ["\\u0", code]
      4 -> ["\\u", code]
    end
  end

  defp map(value),
    do: value |> _map |> Enum.intersperse(?,)
  defp _map(map) do
    for {key, value} <- Map.to_list(map) do
      [escape(key), ?:, _encode(value)]
    end
  end

end
