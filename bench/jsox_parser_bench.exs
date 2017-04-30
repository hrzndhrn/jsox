defmodule JsoxParserBench do
  use Benchfella

  @json [System.cwd, "data", "big.json"]
        |> Path.join
        |> File.read!


  bench "Jsox" do
    Jsox.Parser.parse(@json)
  end

end
