defmodule JsoxTest do

  use ExUnit.Case

  import Jsox

  alias Jsox.SyntaxError

  @test_resources Path.join([System.cwd(), "data"])

  test "parsing zero" do
    assert parse("0") === {:ok, 0}
    assert parse!("0") === 0
  end

  test "skip whitespace" do
    assert parse!("  0") === 0
  end

  test "parsing invalid json" do
    assert parse("-") === {:error, :number, 1}
    assert_raise SyntaxError, "Syntax error on line 1 at column 1",
      fn -> parse!("-") end
  end

  test "parsing test.json" do
    input = load("small.json")

    assert parse(input) === {:ok, %{"small" => 1}}
  end

  test "parsing invalid.json" do
    input = load("invalid.json")

    assert parse(input) === {:error, :json, 57}
    assert_raise SyntaxError, "Syntax error on line 3 at column 27",
      fn -> parse!(input) end
  end

  test "parsing big.json" do
    input = load("big.json")

    assert {:ok, _} = parse(input)
  end

  defp load(filename),
    do: @test_resources
        |> Path.join(filename)
        |> File.read!

end
