defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

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
    assert parse("-.") === {:error, :number, 2}
  end

  test "parsing '1e' raise an exception" do
    assert parse("1e") === {:error, :exponential, 2}
  end

  test "parsing '1e-' raise an exception" do
    assert parse("1e-") === {:error, :exponential, 3}
  end

end
