defmodule ChainCanvasApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :chain_canvas_api,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ChainCanvasApi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8.5"},
      {:phoenix_pubsub, "~> 2.1"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.8"},
      {:req, "~> 0.5"}
    ]
  end
end
