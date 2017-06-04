defmodule ParserBench do
  use Benchfella

  @json [System.cwd, "data", "big.json"]
        |> Path.join
        |> File.read!


  bench "Jsox" do
    Jsox.Parser.parse(@json)
  end

  bench "Poison" do
    Poison.decode!(@json)
  end

  bench "jiffy" do
    :jiffy.decode(@json, [:return_maps])
  end

  bench "JSX" do
    JSX.decode!(@json, [:strict])
  end

  bench "JSON" do
    JSON.decode!(@json)
  end

end
