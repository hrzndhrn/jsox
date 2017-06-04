defmodule Jsox.SyntaxError do
  defexception [:message, :line, :column, :token]

  alias Exception

  def exception(opts) do
    pos = opts[:pos]
    iodata = opts[:iodata]
    token = opts[:token]
    {line, column} = iodata
                     |> String.slice(0, pos)
                     |> String.split("\n")
                     |> position

    message =
      "Syntax error on line #{line} at column #{column}"

    %Jsox.SyntaxError{
      message: message,
      line: line,
      column: column,
      token: token
    }
  end

  defp position(list) do
    {Enum.count(list), list |> List.last |> String.length}
  end

end
