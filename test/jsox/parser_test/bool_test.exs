defmodule Jsox.ParserTest.BoolTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing true" do
    assert parse(~s(true)) === {:ok, true}
  end

  test "parsing false" do
    assert parse(~s(false)) === {:ok, false}
  end

  test "parsing null" do
    assert parse(~s(null)) === {:ok, nil}
  end

  test "parsing list of true false and null" do
    assert parse(~s([true, false, null])) == {:ok, [true, false, nil]}
  end

end
