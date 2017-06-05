defmodule Jsox.JsonSchema.Any do
  @behaviour Jsox.JsonSchema

  def properties(_), do: nil

  def is_valid?(_, _), do: true
end

