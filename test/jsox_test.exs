defmodule JsoxTest do

  use ExUnit.Case

  import Jsox

  test "parsing zero" do
    assert parse("0") == {:ok, 0}
    assert parse!("0") == 0
  end

end
