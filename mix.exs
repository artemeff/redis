defmodule Redis.Mixfile do
  use Mix.Project

  def project do
    [
      app: :redis,
      version: "0.1.0",
      elixir: "~> 1.5",
      deps: deps(),
      package: package(),
      description: "Redis commands for Elixir"
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:benchee, "~> 0.13", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev},
      {:jason, "~> 1.1.2", only: :dev}
    ]
  end

  defp package do
    [
      links: %{"GitHub" => "https://github.com/artemeff/redis"},
      licenses: ["MIT"]
    ]
  end
end
