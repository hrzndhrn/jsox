defmodule JsoxTest do

  use ExUnit.Case

  import Jsox

  alias Jsox.SyntaxError

  test "parsing zero" do
    assert parse("0") === {:ok, 0}
    assert parse!("0") === 0
  end

  test "parsing invalid json" do
    assert parse("-") === {:error, :number, 1}
    assert_raise SyntaxError, "Syntax error on line 1 at column 1",
      fn -> parse!("-") end
  end

end
