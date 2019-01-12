defmodule Redis.Compiler.Documentation do
  @moduledoc false

  import Redis.Compiler.AST

  def make(%{"group" => group, "since" => since, "summary" => summary} = _meta) do
    if elixir_17?() do
      [
        at(:doc, doc(group, summary)),
        at(:doc, [since: since])
      ]
    else
      [
        at(:doc, doc(group, summary))
      ]
    end
  end

  defp doc(group, summary) do
    """
    #{summary}

    Group: `#{group}`.
    """
  end

  defp elixir_17? do
    Version.compare(Version.parse!(System.version), Version.parse!("1.7.0")) != :lt
  end
end
