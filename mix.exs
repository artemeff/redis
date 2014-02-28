defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.1.0-pre.3",
      elixir: ">= 0.12.2",
      deps: deps(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Dependencies
  defp deps(_), do:
    [{ :eredis, "1.0.6", github: "wooga/eredis" }]

end
