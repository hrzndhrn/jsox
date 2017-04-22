defmodule Jsox.Parser do
  @moduledoc """
  A JSON parser according to ECMA-404.

  Standard ECMA-404: The JSON Data Interchange Format
  https://www.ecma-international.org/publications/standards/Ecma-404.htm
  """

  @type json :: map | list | String.t | integer | float | true | false | nil

  @spec parse(iodata) :: {:ok, json} | {:error, String.t}
  def parse(iodata) do
    {:ok, 0}
  end

  @spec parse!(iodata) :: json
  def parse!(iodata) do
    case parse(iodata) do
      {:ok, value} -> value
      {:error, msg} -> raise msg
    end
  end

end
