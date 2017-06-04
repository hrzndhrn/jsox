defprotocol Jsox.Encoder do
  @fallback_to_any true
  def to_json(str, opts \\ [])
end


defimpl Jsox.Encoder, for: BitString do
  alias Jsox.Encoder.Helper

  def to_json("", _opts), do: ~s("")
  def to_json(str, iodata: true), do: str |> Helper.escape
  def to_json(str, _opts), do: str |> Helper.escape |> IO.iodata_to_binary
end


defimpl Jsox.Encoder, for: Atom do
  alias Jsox.Encoder.Helper

  def to_json(true, _opts), do: ~s(true)
  def to_json(false, _opts), do: ~s(false)
  def to_json(nil, _opts), do: ~s(null)
  def to_json(atom, _opts),
    do: atom
        |> Atom.to_string
        |> Helper.escape
        |> IO.iodata_to_binary
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


defimpl Jsox.Encoder, for: Range do

  alias Jsox.Encoder.Helper

  def to_json(range, _opts),
    do: range |> Helper.collection |> IO.iodata_to_binary

end


defimpl Jsox.Encoder, for: MapSet do

  alias Jsox.Encoder.Helper

  def to_json(map_set, _opts) when map_set == %MapSet{}, do: ~s([])

  def to_json(map_set, _opts),
    do: map_set |> Helper.collection |> IO.iodata_to_binary

end


defimpl Jsox.Encoder, for: Any do

  alias Jsox.Encoder.Helper

  def to_json(%{__struct__: _} = struct, _opts),
    do: struct |> Helper.struct |> IO.iodata_to_binary

end
