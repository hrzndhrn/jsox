defmodule Jsox.Encoder.Helper do

  import Jsox.Encoder

  use Bitwise

  @compile {:inline, unicode: 1, _map: 1, _map_item: 1}

  @escape_map %{
    ?\\ => '\\\\',
    ?\" => '\\"',
    ?\n => '\\n',
    ?\r => '\\r',
    ?\b => '\\b',
    ?\f => '\\f',
    ?\t => '\\t',
    ?\/ => '\\/' }

  def escape(str), do: [?", escape(str, []), ?"]

  defp escape("", chars), do: Enum.reverse(chars)

  for {char, seq} <- Map.to_list(@escape_map) do
    defp escape(<<unquote(char)>> <> data, chars) do
      escape(data, [unquote(seq)|chars])
    end
  end

  defp escape(<<char>> <> data, chars) when char <= 0x1F or char == 0x7F do
    IO.puts(">>>>>>>>>>>>>")
    IO.inspect(char)
    escape(data, [unicode(char)|chars])
  end

  defp escape(<<char :: utf8>> <> data, chars) when char in 0x80..0x9F do
    escape(data, [unicode(char)|chars])
  end

  defp escape(<<char :: utf8>> <> data, chars) when char in 0xA0..0xFFFF do
    escape(data, [unicode(char)|chars])
  end

  defp escape(<<char :: utf8>> <> data, chars) when char > 0xFFFF do
    code = char - 0x10000
    esc = [unicode(0xD800 ||| (code >>> 10)),
           unicode(0xDC00 ||| (code &&& 0x3FF))]

    escape(data, [esc|chars])
  end


  defp escape(<<char>> <> data, chars) do
    escape(data, [char|chars])
  end

  defp unicode(char) do
    code = Integer.to_charlist(char, 16)
    case length(code) do
      1 -> ["\\u000", code]
      2 -> ["\\u00", code]
      3 -> ["\\u0", code]
      4 -> ["\\u", code]
    end
  end

  def list([item]), do: [?[, to_json(item, iodata: true) ,?]]

  def list([head|tail]),
    do: [?[, list(tail, [?,, to_json(head, iodata: true)]), ?]]

  defp list([item], acc),
    do: Enum.reverse([to_json(item, iodata: true)|acc])

  defp list([head|tail], acc),
    do: list(tail, [[to_json(head, iodata: true), ?,]|acc])

  def map(map), do: [?{, _map(map), ?}]

  defp _map(map),
    do: map
        |> Map.to_list
        |> Enum.map(&_map_item/1)
        |> Enum.intersperse(?,)

  defp _map_item({key, value}),
    do: [escape(key), ?:, to_json(value, iodata: true)]

end
