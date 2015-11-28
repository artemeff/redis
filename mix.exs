defmodule Exredis.Mixfile do
  use Mix.Project

  @version "0.2.3"

  def project do
    [app: :exredis,
     version: @version,
     elixir: "~> 1.0",
     name: "exredis",
     source_url: "https://github.com/artemeff/exredis",
     homepage_url: "http://artemeff.github.io/exredis",
     deps: deps,
     package: package,
     description: "Redis client for Elixir",
     docs: [readme: "README.md", main: "README",
            source_ref: "v#{@version}",
            source_url: "https://github.com/artemeff/exredis"]]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:eredis]]
  end

  # Dependencies
  defp deps do
    [{:eredis,  ">= 1.0.8"},
     {:benchfella, "~> 0.2.0", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end

  defp package do
    [maintainers: ["Yuri Artemev", "Joakim Kolsjö", "lastcanal", "Aidan Steele",
      "Andrea Leopardi", "Ismael Abreu", "David Rouchy", "David Copeland",
      "Psi", "Andrew Forward", "Sean Stavropoulos"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/artemeff/exredis"}]
  end
end
