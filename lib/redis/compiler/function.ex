defmodule Redis.Compiler.Function do
  @moduledoc false

  use Redis.Compiler.AST

  def make(nil) do
    []
  end
  def make(arguments) do
    Enum.reduce(arguments, [], fn(arg, acc) ->
      case ast_pipe(arg) do
        {:append, ast, _state} -> acc ++ [ast]
        {:skip, _state} -> acc
      end
    end)
  end

  ### ast functions

  defp ast_pipe(arg) do
    State.new(arg)
    |> State.walk(&ast_name/1)
    |> State.walk(&ast_optional/1)
    |> State.walk(&ast_type/1)
    |> State.walk(&ast_variadic/1)
    |> State.walk(&ast_command/1)
    |> State.walk(&ast_multiple/1)
    |> State.walk(&ast_close/1)
    |> State.finalize()
  end

  defp ast_name(%State{arg: %{"command" => command}} = state) do
    %State{state | name: ident(command)}
  end
  defp ast_name(%State{arg: %{"name" => names}} = state) when is_list(names) do
    %State{state | name: ident(Enum.join(names, "_"))}
  end
  defp ast_name(%State{arg: %{"name" => name}} = state) do
    %State{state | name: ident(name)}
  end

  defp ast_optional(%State{arg: %{"optional" => true}} = state) do
    %State{state | ast: pipe(ident_var(:opts), types_func(:optional, [state.name]))}
  end
  defp ast_optional(%State{} = state) do
    %State{state | ast: ident_var(state.name)}
  end

  defp ast_type(%State{arg: %{"type" => types}} = state) when is_list(types) do
    %State{state | ast: pipe(state.ast, types_func(:tuple, [state.name, length(types)]))}
  end
  # for optional enums with command (like `BITFIELD`) - choose value from accepts
  defp ast_type(%State{arg: %{"type" => "enum", "enum" => enum, "optional" => true, "command" => _}} = state) do
    %State{state | ast: pipe(state.ast, types_func(:enum, [ident(state.name), accepts(enum)]))}
  end
  # for optional enums without command discard `opts |> T.optional` call and use `opts |> T.enum_atom`
  defp ast_type(%State{arg: %{"type" => "enum", "enum" => enum, "optional" => true}} = state) do
    %State{state | ast: pipe(ident_var(:opts), types_func(:enum_atom, [ident(state.name), accepts(enum)]))}
  end
  # for non-optional enums with one value (like `STREAMS` in `XREAD`, `XREADGROUP`) - just place it as is
  defp ast_type(%State{arg: %{"type" => "enum", "enum" => [value]}} = state) do
    %State{state | halt: true, ast: [" ", value]}
  end
  # for non-optional enums with more that one value (like `ZREVRANGE`, `CLIENT REPLY`) - choose value from accepts
  defp ast_type(%State{arg: %{"type" => "enum", "enum" => enum}} = state) do
    %State{state | ast: pipe(state.ast, types_func(:enum, [ident(state.name), accepts(enum)]))}
  end
  defp ast_type(%State{arg: %{"type" => _type}} = state) do
    state
  end
  # special case when argument dont have `type` field but it is enum
  defp ast_type(%State{arg: %{"enum" => enum, "optional" => true}} = state) do
    %State{state | ast: pipe(ident_var(:opts), types_func(:enum_atom, [ident(state.name), accepts(enum)]))}
  end

  defp ast_variadic(%State{arg: %{"variadic" => true}} = state) do
    %State{state | ast: pipe(state.ast, types_func(:variadic, [state.name, ident_var(:key)]))}
  end
  defp ast_variadic(%State{} = state) do
    state
  end

  defp ast_command(%State{arg: %{"command" => command}} = state) do
    %State{state | ast: pipe(state.ast, types_func(:command, [command]))}
  end
  defp ast_command(%State{} = state) do
    state
  end

  defp ast_multiple(%State{ast: {:|>, _, [value, validator]}, arg: %{"multiple" => true}} = state) do
    %State{state | ast: pipe(value, types_func(:multiple, [state.name, validator_lambda(validator)]))}
  end
  defp ast_multiple(%State{arg: %{"multiple" => true}} = state) do
    %State{state | ast: pipe(state.ast, types_func(:multiple, [state.name]))}
  end
  defp ast_multiple(%State{} = state) do
    state
  end

  defp ast_close(%State{} = state) do
    %State{state | ast: types_func(:close, [state.ast])}
  end

  ### internal functions

  defp validator_lambda(validator) do
    quote do
      fn(v) -> v |> unquote(validator) end
    end
  end

  # fix for `MIGRATE` command
  defp accepts(["key", "\"\""]) do
    :erlang.make_fun(Redis.Compiler.Types, :as_is, 1)
  end
  defp accepts(enum) do
    {:%{}, [], Enum.map(enum, &accept/1)}
  end

  # fix for `SET` command
  defp accept("EX seconds") do
    {ident(:ex), "EX"}
  end
  defp accept("PX milliseconds") do
    {ident(:px), "PX"}
  end
  defp accept(enum) do
    {ident(enum), enum}
  end
end
