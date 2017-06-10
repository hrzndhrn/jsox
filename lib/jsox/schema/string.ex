defmodule Jsox.Schema.String do
  @behaviour Jsox.Schema

  def properties(properties), do: properties

  def is_valid?(_schema, value) when is_binary(value), do: true
  def is_valid?(_, _), do: false
end
