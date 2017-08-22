defmodule Headlines.Mixfile do
  use Mix.Project

  def project do
    [
      app: :headlines,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:floki, "~> 0.18.0"},
      {:httpoison, "~> 0.13"},
      {:csvlixir, "~> 2.0.3"}
    ]
  end
end
