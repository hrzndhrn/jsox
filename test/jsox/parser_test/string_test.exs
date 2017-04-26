defmodule Jsox.ParserTest.StringTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing string" do
    assert parse(~S("a")) === {:ok, ~s(a)}
    assert parse(~S("abc")) === {:ok, ~s(abc)}
    assert parse(~S("Hello, world!")) === {:ok, ~s(Hello, world!)}
  end

  test "parsing string with escapes" do
    # qutation mark
    assert parse(~S("a\"b")) === {:ok, ~s(a\"b)}
    # reverse solidus
    assert parse(~S("\\")) === {:ok, ~s(\\)}
    assert parse(~S("a\\b")) === {:ok, ~s(a\\b)}
    # solidus
    assert parse(~S("a\/b")) === {:ok, ~s(a/b)}
    # newline
    assert parse(~S("a\nb")) === {:ok, ~s(a\nb)}
    # backspace
    assert parse(~S("a\bb")) === {:ok, ~s(a\bb)}
    # formfeed
    assert parse(~S("a\fb")) === {:ok, ~s(a\fb)}
    # horizontal tab
    assert parse(~S("a\tb")) === {:ok, ~s(a\tb)}
    # carriage return
    assert parse(~S("a\rb")) === {:ok, ~s(a\rb)}
  end

  test "parsing unicode" do
    assert parse(~S("\u2195")) == {:ok, ~s(\u2195)}
    assert parse(~S("\u2936")) == {:ok, ~s(⤶)}
    assert parse(~S("\u2936\u2936")) == {:ok, ~s(⤶⤶)}
  end

  test "parsing surrogate pairs" do
    assert parse(~S("\uD834\uDD1E")) == {:ok, ~s(𝄞)}
  end

  test "parsing invalid escape sequence raise an exception" do
    assert parse(~S("\x")) == {:error, :string, 1}
  end

end
