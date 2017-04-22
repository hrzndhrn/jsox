defmodule Jsox.ParserTest do

  use ExUnit.Case, async: true

  import Jsox.Parser

  test "parsing zero" do
    assert parse!("0") == 0
  end

end
