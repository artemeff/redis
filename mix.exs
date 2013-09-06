defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.1.0-pre.2",
      deps: deps(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Dependencies
  defp deps(:prod), do:
    [{ :eredis, "1.0.6", [ github: "wooga/eredis", tag: "v1.0.6" ] }]

  defp deps(_), do:
    deps(:prod) ++
      [{ :benchmark, github: "meh/elixir-benchmark" }]

end
