defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.1.2",
      elixir: "~> 1.0.0",
      name: "exredis",
      source_url: "https://github.com/artemeff/exredis",
      homepage_url: "http://artemeff.github.io/exredis",
      deps: deps,
      package: package,
      description: "Redis client for Elixir",
      docs: [readme: true, main: "README.md"] ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Dependencies
  defp deps do
    [{:eredis, github: "wooga/eredis", tag: "v1.0.8"}]
  end

  defp package do
    [
      contributors: ["Yuri Artemev", "Joakim Kolsjö", "lastcanal", "Aidan Steele",
        "Andrea Leopardi", "Ismael Abreu", "David Rouchy", "David Copeland",
        "Psi", "Andrew Forward", "Sean Stavropoulos"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/artemeff/exredis"}
    ]
  end
end
