defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [app: :exredis,
     version: "0.3.0",
     elixir: "~> 1.5",
     name: "exredis",
     source_url: "https://github.com/artemeff/exredis",
     homepage_url: "https://hexdocs.pm/exredis",
     deps: deps(),
     package: package(),
     description: "Redis client for Elixir"]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:eredis]]
  end

  # Dependencies
  defp deps do
    [{:eredis,  ">= 1.0.8"},
     {:benchfella, "~> 0.3.0", only: :dev},
     {:earmark, "~> 1.2", only: :dev},
     {:ex_doc, "~> 0.19", only: :dev}]
  end

  defp package do
    [maintainers: ["Yuri Artemev", "Joakim Kolsjö", "lastcanal", "Aidan Steele",
      "Andrea Leopardi", "Ismael Abreu", "David Rouchy", "David Copeland",
      "Psi", "Andrew Forward", "Sean Stavropoulos"],
     files: ["lib", "mix.exs", "README.md"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/artemeff/exredis"}]
  end
end
