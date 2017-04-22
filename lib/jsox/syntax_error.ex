defmodule Jsox.SyntaxError do
  defexception [:message, :line, :column]

  def exception(opts) do
    line = opts[:line]
    column = opts[:column]
    message =
      "Syntax error on line #{line} at column #{column}"

    %Jsox.SyntaxError{
      message: message,
      line: line,
      column: column
    }
  end
end
