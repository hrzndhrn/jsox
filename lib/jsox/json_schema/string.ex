defmodule Jsox.JsonSchema.String do
  @behaviour Jsox.JsonSchema

  def properties(properties), do: properties

  def is_valid?(_schema, value) when is_binary(value), do: true
  def is_valid?(_, _), do: false
end
