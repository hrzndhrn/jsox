defprotocol Jsox.Encoder do

  def to_json(str, opts \\ [])

end


defimpl Jsox.Encoder, for: BitString do

  alias Jsox.Encoder.Helper

  def to_json("", _opts), do: ~s("")

  def to_json(str, iodata: true), do: str |> Helper.escape

  def to_json(str, _opts), do: str |> Helper.escape |> IO.iodata_to_binary

end


defimpl Jsox.Encoder, for: Atom do

  def to_json(true, _opts), do: ~s(true)

  def to_json(false, _opts), do: ~s(false)

  def to_json(nil, _opts), do: ~s(null)

end


defimpl Jsox.Encoder, for: Integer do

  def to_json(value, _opts), do: Integer.to_string(value)

end


defimpl Jsox.Encoder, for: Float do

  def to_json(value, _opts), do: Float.to_string(value)

end


defimpl Jsox.Encoder, for: List do

  alias Jsox.Encoder.Helper

  def to_json([], _opts), do: ~s([])

  def to_json(list, iodata: true), do: list |> Helper.list

  def to_json(list, _opts), do: list |> Helper.list |> IO.iodata_to_binary

end


defimpl Jsox.Encoder, for: Map do

  alias Jsox.Encoder.Helper

  def to_json(map, _opts) when map === %{}, do: ~s({})

  def to_json(map, iodata: true), do: map |> Helper.map

  def to_json(map, _opts), do: map |> Helper.map |> IO.iodata_to_binary

end
