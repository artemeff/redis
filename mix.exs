defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Dependencies
  defp deps do
    [
      { :eredis, "1.0.5", [ github: "wooga/eredis", tag: "v1.0.5" ] }
    ]
  end
end
