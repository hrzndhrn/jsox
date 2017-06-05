defmodule Jsox.JsonSchemaTest do

  use ExUnit.Case, async: true

  alias Jsox.JsonSchema
  import Jsox.JsonSchema, only: [is_valid?: 2]

  test "any schema" do
    schema = JsonSchema.create()
    assert is_valid?(schema, "foo")
    assert is_valid?(schema, 1)
    assert is_valid?(schema, %{bla: 1})
  end

  describe "string schema" do
    test "simple string schema" do
      schema = JsonSchema.create(:string)
      assert is_valid?(schema, "foo")
      refute is_valid?(schema, 1)
    end
  end
end
