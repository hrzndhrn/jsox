defmodule Jsox.Schema.Null do
  @behaviour Jsox.Schema

  def properties(_), do: nil

  def is_valid?(_, _), do: false
end
