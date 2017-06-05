defmodule Jsox.JsonSchema do
  alias __MODULE__, as: Schema
  alias Jsox.JsonSchema

  defstruct type: :any, properties: nil

  @types %{
    any: JsonSchema.Any,
    string: JsonSchema.String
  }

  @callback is_valid?(%Schema{}, any) :: boolean
  @callback properties(any) :: struct

  def create(), do: %Schema{}
  def create(:string, properties \\ []) do
    %Schema{type: :string, properties: JsonSchema.String.properties(properties)}
  end

  for {type, xmodule} <- Map.to_list(@types) do
    def is_valid?(%Schema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema, value)
    end
  end
end
