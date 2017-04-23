defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing zero float" do
    assert parse("0.0") == {:ok, 0.0}
  end

  test "parsing positive float" do
    assert parse("0.0") == {:ok, 0.0}
    assert parse("0.1") == {:ok, 0.1}
    assert parse("0.11") == {:ok, 0.11}
    assert parse("1.1") == {:ok, 1.1}
    assert parse("1234.567") == {:ok, 1234.567}
  end

  test "parsing negative float" do
    assert parse("-0.0") == {:ok, -0.0}
    assert parse("-0.1") == {:ok, -0.1}
    assert parse("-0.11") == {:ok, -0.11}
    assert parse("-1.1") == {:ok, -1.1}
    assert parse("-1234.567") == {:ok, -1234.567}
  end

end
