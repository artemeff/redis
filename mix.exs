defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.1.0",
      elixir: "~> 1.0.0",
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
    [
      { :eredis, "1.0.6", github: "wooga/eredis", ref: "471dd" }
    ]
  end

  defp package do
    [
      contributors: ["Yuri Artemev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/artemeff/exredis"}
    ]
  end
end
