defmodule Redis.Compiler.Arguments do
  @moduledoc false

  use Redis.Compiler.AST

  def make(nil) do
    []
  end
  def make(arguments) do
    init = %{ast: [], state: %{append_opts_ast: false}}

    Enum.reduce(arguments, init, fn(arg, acc) ->
      case ast_pipe(arg, acc.state) do
        {:append, ast, state} -> %{acc | ast: acc.ast ++ [ast], state: state}
        {:skip, state} -> %{acc | state: state}
      end
    end)
    |> maybe_append_opts_argument()
    |> Map.fetch!(:ast)
  end

  ### finalization functions

  defp maybe_append_opts_argument(%{ast: ast, state: %{append_opts_ast: true}} = acc) do
    %{acc | ast: ast ++ [optional(ident_var(:opts), [])]}
  end
  defp maybe_append_opts_argument(acc) do
    acc
  end

  ### functions for each argument

  defp ast_pipe(arg, global_state) do
    State.new(arg, global_state)
    |> State.walk(&ast_name/1)
    |> State.walk(&ast_required_simple_enum/1)
    |> State.walk(&ast_optional/1)
    |> State.finalize()
  end

  defp ast_name(%State{arg: %{"command" => command}} = state) do
    %State{state | ast: ident_var(command)}
  end
  defp ast_name(%State{arg: %{"name" => names}} = state) when is_list(names) do
    %State{state | ast: ident_var(Enum.join(names, "_"))}
  end
  defp ast_name(%State{arg: %{"name" => name}} = state) do
    %State{state | ast: ident_var(name)}
  end

  # for non-optional enums with one value (like `STREAMS` in `XREAD`, `XREADGROUP`) - skip argument
  def ast_required_simple_enum(%State{arg: %{"type" => "enum", "enum" => [_]}} = state) do
    %State{state | ast: nil}
  end
  def ast_required_simple_enum(%State{} = state) do
    state
  end

  defp ast_optional(%State{arg: %{"optional" => true}} = state) do
    %State{state | ast: nil, halt: true,
                   global_state: %{state.global_state | append_opts_ast: true}}
  end
  defp ast_optional(state) do
    state
  end
end
