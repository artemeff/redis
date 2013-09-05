defmodule Exredis.Mixfile do
  use Mix.Project

  def project do
    [ app: :exredis,
      version: "0.1.0-pre.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Dependencies
  defp deps do
    [
      { :eredis, "1.0.6", [ github: "wooga/eredis", tag: "v1.0.6" ] }
    ]
  end
end
