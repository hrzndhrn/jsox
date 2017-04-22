defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  alias Jsox.SyntaxError

  test "parsing zero" do
    assert parse("0") == {:ok, 0}
  end

  test "parsing positive numbers" do
    assert parse("1") == {:ok, 1}
    assert parse("12") == {:ok, 12}
    assert parse("123") == {:ok, 123}
  end

  test "parsing negative numbers" do
    assert parse("-1") == {:ok, -1}
    assert parse("-12") == {:ok, -12}
    assert parse("-123") == {:ok, -123}
  end

  test "parsing '-' raise an exception" do
    assert_raise SyntaxError, "Syntax error on line 1 at column 1",
      fn -> parse("-") end
  end

end
