defmodule Jsox.EncoderTest do

  use ExUnit.Case, async: true

  import Jsox.Encoder
  alias Jsox

  defp key_map(map) do
    switch = fn(key) ->
      if is_atom(key), do: Atom.to_string(key), else: String.to_atom(key)
    end

    for {key, val} <- map,
      into: %{},
      do: {switch.(key), val}
  end


  describe "encode atoms" do
    test "encode true",
      do: assert to_json(true) === ~S(true)

    test "encode false",
      do: assert to_json(false) === ~S(false)

    test "encode nil",
      do: assert to_json(nil) === ~S(null)

    test "encode an atom",
      do: assert to_json(:atom) === ~S("atom")

  end

  describe "encode integer" do
    test "encode 0",
      do: assert to_json(0) === ~S(0)

    test "encode 10",
      do: assert to_json(10) === ~S(10)

    test "encode -10",
      do: assert to_json(-10) === ~S(-10)

    test "encode 1234",
      do: assert to_json(1234) === ~S(1234)

    test "encode -1234",
      do: assert to_json(-1234) === ~S(-1234)
  end

  test "encode float" do
    assert to_json(0.0) === ~S(0.0)
    assert to_json(-12.34) === ~S(-12.34)
    assert to_json(12.34) === ~S(12.34)
  end

  test "encode empty string",
    do: assert to_json("") === ~s("")

  test "encode empty string to iodata",
    do: assert to_json("", iodata: true) === ~s("")

  test "encode simple string",
    do: assert to_json("abc") === ~S("abc")

  test "encode simple string to iodata",
    do: assert to_json("abc", iodata: true) === [?", 'abc', ?"]

  test "encode string conatining \\n",
    do: assert to_json("a\nbc") === ~S("a\nbc")

  test "encode empty list",
    do: assert to_json([]) === ~S([])

  test "encode list with one element" do
    assert to_json([1]) === ~S([1])
    assert to_json(["one"]) === ~S(["one"])
  end

  test "encode list",
    do: assert to_json([1, "abc", 3]) === ~S([1,"abc",3])

  test "encode [[\"string\"]]",
    do: assert to_json([["string"]]) === ~S([["string"]])

  test "encode [[\"string\"]] to iodata" do
    expected = [91, [91, [34, 'string', 34], 93], 93]
    assert to_json([["string"]], iodata: true) === expected
  end

  test "encode nested list" do
    input = [1, ["abc", 43, [9, 8]], 3]
    expected = ~S([1,["abc",43,[9,8]],3])
    assert to_json(input) === expected
  end

  test "encode list with en empty list as element", do:
    assert to_json(["a", [], 1]) === ~S(["a",[],1])

  test "encode empty map",
    do: assert to_json(%{}) == ~S({})

  test "encode map",
    do: assert to_json(%{"a" => 1, "b" => "c"}) === ~S({"a":1,"b":"c"})

  test "encode nested map",
    do: assert to_json(%{"a" => %{"b" => "c"}}) === ~S({"a":{"b":"c"}})

  test "encode unicode",
    do: assert to_json(~s(a⤶b)) === ~S("a\u2936b")

  test "encode unicode surrogate",
    do: assert to_json(~s(a𝄞b)) === ~S("a\uD834\uDD1Eb")

  test "encode Range",
    do: assert to_json(1..3) === ~S([1,2,3])

  test "encode empty MapSet",
    do: assert to_json(MapSet.new()) === ~S([])

  test "encode MapSet" do
    list = ["map", "set", 1, 1]
    map_set = MapSet.new(list)
    json = to_json(map_set)
    json_list = json |> Jsox.parse! |> Enum.sort
    map_set_list = map_set |> Enum.to_list |> Enum.sort

    assert String.contains?(json, ~S("map"))
    assert String.contains?(json, ~S("set"))
    assert String.contains?(json, ~S(1))
    assert String.starts_with?(json, ~S([))
    assert String.ends_with?(json, ~S(]))
    assert map_set_list === json_list
  end

  describe "encode structs" do
    defmodule User do
      defstruct name: "", age: 0
    end

    test "encode struct" do
      user = %User{name: "John", age: 33}
      json = to_json(user)

      assert Jsox.parse!(json) === user |> Map.from_struct |> key_map
    end
  end

end
