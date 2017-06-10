defmodule Jsox.SchemaTest do

  use ExUnit.Case, async: true

  alias Jsox.Schema
  import Jsox.Schema, only: [is_valid?: 2]

  test "any schema" do
    schema = Schema.create()
    assert is_valid?(schema, "foo")
    assert is_valid?(schema, 1)
    assert is_valid?(schema, %{bla: 1})
  end

  describe "string schema" do
    test "simple string schema" do
      schema = Schema.create(:string)
      assert is_valid?(schema, "foo")
      refute is_valid?(schema, 1)
    end
  end
end
