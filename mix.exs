defmodule BMP280.MixProject do
  use Mix.Project

  @version "0.2.12"
  @source_url "https://github.com/elixir-sensors/bmp280"

  def project do
    [
      app: :bmp280,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      description: description(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs,
        dialyzer: :lint,
        credo: :lint
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Use Bosch BMP280, BME280, and BME680 sensors in Elixir"
  end

  defp package do
    %{
      files: [
        "lib",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE",
        "CHANGELOG.md"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      {:circuits_i2c, "~> 1.0 or ~> 0.3.0"},
      {:ex_doc, "~> 0.29", only: :docs, runtime: false},
      {:dialyxir, "~> 1.1", only: :lint, runtime: false},
      {:credo, "~> 1.5", only: :lint, runtime: false},
      {:credo_binary_patterns, "~> 0.2.2", only: :lint, runtime: false}
    ]
  end

  defp dialyzer() do
    [
      flags: [:extra_return, :unmatched_returns, :error_handling, :underspecs]
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
