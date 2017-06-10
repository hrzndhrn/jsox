defmodule Jsox.Schema.Any do
  @behaviour Jsox.Schema

  def properties(_), do: nil

  def is_valid?(_, _), do: true
end

