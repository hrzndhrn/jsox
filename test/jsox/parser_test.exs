defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

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

end
