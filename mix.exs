defmodule Jsox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jsox,
      version: "0.1.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],

      # Docs
      name: "Jsox",
      source_url: "https://github.com/hrzndhrn/jsox",
      docs: [main: "Jsox"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:benchfella, "~> 0.3", only: :bench},
      {:poison, github: "devinus/poison", only: :bench},
      {:exjsx, github: "talentdeficit/exjsx", only: :bench},
      {:json, github: "cblage/elixir-json", only: :bench},
      {:jiffy, github: "davisp/jiffy", only: :bench}
    ]
  end
end
