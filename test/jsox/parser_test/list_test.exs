defmodule Jsox.ParserTest.ListTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing empty list" do
    assert parse("[]") === {:ok, []}
  end

  test "parsing list of length 1" do
    assert parse("[1]") === {:ok, [1]}
  end

  test "parsing list of length 2" do
    assert parse("[1,2]") === {:ok, [1, 2]}
  end

  test "parsing list of length 5" do
    assert parse("[1,2,3,4,5]") === {:ok, [1, 2, 3, 4, 5]}
    assert parse(~s([ 1, 2,"three", 4 , 5 ])) === {:ok, [1, 2, "three", 4, 5]}
  end

  test "list of lists" do
    assert parse(~s([[1,2], ["a", "b"]])) === {:ok, [[1,2], ["a", "b"]]}
  end

  test "invalid list" do
    assert parse(~s([,])) === {:error, :list, 1}
    assert parse(~s([1,])) === {:error, :json, 4}
    assert parse(~s([1,,2])) === {:error, :json, 4}
    assert parse(~s([1 2])) === {:error, :list, 3}
    assert parse(~s([1,2,])) === {:error, :json, 6}
    assert parse(~s([1,2,3,])) === {:error, :json, 8}
    assert parse(~s([1,2,,3])) === {:error, :json, 6}
  end
end
