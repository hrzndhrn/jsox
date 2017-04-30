defmodule Jsox.EncoderTest do

  use ExUnit.Case, async: true

  import Jsox.Encoder

  test "encode empty string",
    do: assert encode("") === {:ok, ~s("")}

  test "encode true",
    do: assert encode(true) === {:ok, ~s(true)}

  test "encode false",
    do: assert encode(false) === {:ok, ~s(false)}

  test "encode nil",
    do: assert encode(nil) === {:ok, ~s(null)}

  test "encode integer" do
    assert encode(-1234) === {:ok, ~S(-1234)}
    assert encode(-10) === {:ok, ~S(-10)}
    assert encode(0) === {:ok, ~S(0)}
    assert encode(10) === {:ok, ~S(10)}
    assert encode(1234) === {:ok, ~S(1234)}
  end

  test "encode float" do
    assert encode(-12.34) === {:ok, ~S(-12.34)}
    assert encode(12.34) === {:ok, ~S(12.34)}
  end

  test "encode simple string",
    do: assert encode("abc") === {:ok, ~S("abc")}

  test "encode string conatining \\n",
    do: assert encode("a\nbc") === {:ok, ~S("a\nbc")}

  test "encode empty list",
    do: assert encode([]) === {:ok, ~S([])}

  test "encode list",
    do: assert encode([1, "abc", 3]) === {:ok, ~S([1,"abc",3])}

  test "encode nested list" do
    input = [1, ["abc", 43, [9, 8]], 3]
    expected = ~S([1,["abc",43,[9,8]],3])
    assert encode(input) === {:ok, expected}
  end

  test "encode empty map",
    do: assert encode(%{}) == {:ok, ~S({})}

  test "encode map",
    do: assert encode(%{"a" => 1, "b" => "c"}) === {:ok, ~S({"a":1,"b":"c"})}

  test "encode nested map",
    do: assert encode(%{"a" => %{"b" => "c"}}) === {:ok, ~S({"a":{"b":"c"}})}

  test "encode unicode",
    do: assert encode(~s(a⤶b)) == {:ok, ~S("a\u2936b")}

  @tag :skip
  test "encode unicode surrogate",
    do: assert encode(~s(a𝄞b)) == {:ok, ~S("a\uD834\uDD1Eb")}

end
