defmodule Symbiosis.MixProject do
  use Mix.Project

  def project do
    [
      app: :symbiosis,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :peerage],
      mod: {Symbiosis.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:peerage, "~> 1.0.2"},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end
end
