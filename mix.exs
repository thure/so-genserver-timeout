defmodule GenServerTimeoutBattery.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_server_timeout_battery,
      name: "GenServerTimeoutBattery",
      version: "0.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      test_coverage: test(),
      preferred_cli_env: cli_env()
    ]
  end

  def test do
    [
      tool: ExCoveralls,
      output: "_cover"
    ]
  end

  def cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
      Shared utility functions for working with geometry.
    """
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10.5", only: :test, runtime: false},
      {:uuid, "~> 1.1"}
    ]
  end
end
