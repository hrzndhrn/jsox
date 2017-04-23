defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  alias Jsox.SyntaxError

  test "parsing zero float" do
    assert parse("0.0") === {:ok, 0.0}
  end

  test "parsing positive float" do
    assert parse("0.0") === {:ok, 0.0}
    assert parse("0.1") === {:ok, 0.1}
    assert parse("0.11") === {:ok, 0.11}
    assert parse("1.1") === {:ok, 1.1}
    assert parse("1234.567") === {:ok, 1234.567}
  end

  test "parsing negative float" do
    assert parse("-0.0") === {:ok, -0.0}
    assert parse("-0.1") === {:ok, -0.1}
    assert parse("-0.11") === {:ok, -0.11}
    assert parse("-1.1") === {:ok, -1.1}
    assert parse("-1234.567") === {:ok, -1234.567}
  end

  test "parsing scientific positive float" do
    assert parse("0e0") === {:ok, 0.0}
    assert parse("1e0") === {:ok, 1.0}
    assert parse("1e1") === {:ok, 10.0}
    assert parse("11e10") === {:ok, 110000000000.0}

    assert parse("1.1e1") === {:ok, 11.0}
    assert parse("1e-1") === {:ok, 0.1}
    assert parse("11e-11") === {:ok, 1.1e-10}
  end

  test "parsing scientific negative float" do
    assert parse("-0e0") === {:ok, 0.0}
    assert parse("-1e0") === {:ok, -1.0}
    assert parse("-1e1") === {:ok, -10.0}
    assert parse("-11e10") === {:ok, -110000000000.0}
  end

  test "parsing '-.' raise an exception" do
    assert_raise SyntaxError, "Syntax error on line 1 at column 1",
      fn -> parse("-.") end
  end

  test "parsing '1e' raise an exception" do
    assert_raise SyntaxError, "Syntax error on line 1 at column 2",
      fn -> parse("1e") end
  end

  test "parsing '1e-' raise an exception" do
    assert_raise SyntaxError, "Syntax error on line 1 at column 3",
      fn -> parse("1e-") end
  end

end
