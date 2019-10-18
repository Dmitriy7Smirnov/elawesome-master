defmodule Elawesome.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elawesome,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: get_apps(),
      mod: {Elawesome, []}
    ]
  end

  defp get_apps do
    [
      :inets,
      :ssl,
      :logger,
      :cowboy,
      :plug,
      :phoenix,
      :earmark
    ]
  end

  # Dependencies
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:phoenix, "~> 1.4"},
      {:plug_cowboy, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:floki, "~> 0.23.0"},
      {:earmark, "~> 1.4"}
    ]
  end
end
