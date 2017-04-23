defmodule Jsox.ParserTest.StringTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  alias Jsox.SyntaxError

  defmacro sigil_q({:<<>>, _, [binary]}, [])
    when is_binary(binary),
    do: unquote(~s(")) <> binary <> unquote(~s("))

  test "parsing string" do
    assert parse(~q(a)) === {:ok, "a"}
    assert parse(~q(abc)) === {:ok, "abc"}
    assert parse(~q(Hello, world!)) === {:ok, "Hello, world!"}
  end

  test "parsing string with escapes" do
    # qutation mark
    assert parse(~q(a\"b)) === {:ok, ~s(a\"b)}
    # reverse solidus
    assert parse(~q(\\)) === {:ok, ~s(\\)}
    assert parse(~q(a\\b)) === {:ok, ~s(a\\b)}
    # solidus
    assert parse(~q(a\/b)) === {:ok, ~s(a/b)}
    # newline
    assert parse(~q(a\nb)) === {:ok, ~s(a\nb)}
    # backspace
    assert parse(~q(a\bb)) === {:ok, ~s(a\bb)}
    # formfeed
    assert parse(~q(a\fb)) === {:ok, ~s(a\fb)}
    # horizontal tab
    assert parse(~q(a\tb)) === {:ok, ~s(a\tb)}
    # carriage return
    assert parse(~q(a\rb)) === {:ok, ~s(a\rb)}
  end

  test "parsing unicode" do
    assert parse(~q(\u2195)) == {:ok, ~s(\u2195)}
    assert parse(~q(\u2936)) == {:ok, ~s(⤶)}
    assert parse(~q(\u2936\u2936)) == {:ok, ~s(⤶⤶)}
  end

	test "parsing surrogate pairs" do
    assert parse(~s("\\uD834\\uDD1E")) == {:ok, "𝄞"}
	end

  test "parsing invalid escape sequence raise an exception" do
    assert_raise SyntaxError, "Syntax error on line 1 at column 1",
      fn -> parse(~q(\x)) end
  end

end
