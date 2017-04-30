defmodule Jsox.ParserTest.MapTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing empty map" do
    assert parse(~s({})) === {:ok, %{}}
  end

  test "parsiing map with one item" do
    assert parse(~s({"a":1})) === {:ok, %{"a" => 1}}
  end

  test "parsiing map with two items" do
    assert parse(~s({"a" : 1, "b" : 2})) === {:ok, %{"a" => 1, "b" => 2}}
  end

  test "parsing nested maps" do
    assert parse(~s({"a" : { "b" :2 }})) === {:ok, %{"a" => %{"b" => 2}}}
  end

  test "parsing deep nested maps" do
    input = ~s({"a":1,"z":{"b":2,"y":{"c":3},"d":4},"e":5})
    expected = %{
      "a" => 1,
      "z" => %{
        "b" => 2,
        "y" => %{"c" => 3},
        "d" => 4
      },
      "e" => 5
    }
    assert parse(input) === {:ok, expected}
  end

  test "get an error for invalid maps" do
    assert parse(~s({ : { })) === {:error, :map, 3}
    assert parse(~s( "b" : 2})) === {:error, :eof, 3}
    assert parse(~s({"a" : 1 "b" : 2})) === {:error, :map, 10}
    assert parse(~s({"a" : 1, "b" : 2,})) === {:error, :key, 19}
  end

end
