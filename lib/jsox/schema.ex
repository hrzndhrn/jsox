defmodule Jsox.Schema do
  alias __MODULE__, as: Schema

  defstruct type: :any, properties: nil

  @types %{
    any: Jsox.Schema.Any,
    null: Jsox.Schema.Null,
    boolean: Jsox.Schema.Boolean,
    object: Jsox.Schema.Object,
    array: Jsox.Schema.Array,
    number: Jsox.Schema.Number,
    string: Jsox.Schema.String,
    enum: Jsox.Schema.Enum
  }

  @callback is_valid?(%Schema{}, any) :: boolean
  @callback properties(any) :: struct

  def create(), do: %Schema{}
  def create(:string, properties \\ []) do
    %Schema{type: :string, properties: Schema.String.properties(properties)}
  end

  for {type, xmodule} <- Map.to_list(@types) do
    def is_valid?(%Schema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema, value)
    end
  end
end
