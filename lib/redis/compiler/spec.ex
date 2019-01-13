defmodule Redis.Compiler.Spec do
  @moduledoc false

  use Redis.Compiler.AST

  def make(command, nil) do
    double_colon_ast(ident_var(command), ident_var(:iolist))
  end
  def make(command, arguments) do
    init = %{ast: [], state: %{append_opts_ast: false, opts: []}}

    Enum.reduce(arguments, init, fn(arg, acc) ->
      case ast_pipe(arg, acc.state) do
        {:append, ast, state} -> %{acc | ast: acc.ast ++ [ast], state: state}
        {:skip, state} -> %{acc | state: state}
      end
    end)
    |> maybe_append_opts_argument()
    |> wrap_in_function_spec(command)
  end

  ### finalization functions

  defp maybe_append_opts_argument(%{ast: ast, state: %{append_opts_ast: true, opts: opts}} = acc) do
    opts =
      Enum.map(opts, fn({types, meta}) ->
        key_values_type(meta, types)
      end)

    opts =
      Enum.reduce(tl(opts), hd(opts), fn(opt, acc) ->
        {:|, [], [opt, acc]}
      end)

    %{acc | ast: ast ++ [double_colon_ast(ident_var(:opts), [opts])]}
  end
  defp maybe_append_opts_argument(acc) do
    acc
  end

  defp key_values_type(%{command: false, enum: true}, {name, types}) do
    if name == types do
      types
    else
      {:|, [], [types, {name, types}]}
    end
  end
  defp key_values_type(_meta, types) do
    types
  end

  defp wrap_in_function_spec(%{ast: ast}, command) do
    double_colon_ast({ident(command), [], ast}, ident_var(:iolist))
  end

  ### functions for each argument

  defp ast_pipe(arg, global_state) do
    State.new(arg, global_state)
    |> State.walk(&ast_name/1)
    |> State.walk(&ast_spec/1)
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

  # for non-optional enums with one value (like `XREAD`, `XREADGROUP`) - skip argument
  defp ast_spec(%State{arg: %{"type" => "enum" = type, "enum" => [_]}} = state) do
    spec_optional({{state.name, choose_type(type, state.arg)}, spec_meta(state)}, state)
  end
  defp ast_spec(%State{arg: %{"type" => type, "optional" => true}} = state) do
    spec_optional({{state.name, choose_type(type, state.arg)}, spec_meta(state)}, state)
  end
  # special case when argument dont have `type` field but it is enum
  defp ast_spec(%State{arg: %{"enum" => _, "optional" => true}} = state) do
    spec_optional({{state.name, choose_type("enum", state.arg)}, spec_meta(state)}, state)
  end
  defp ast_spec(%State{arg: %{"type" => type}} = state) do
    %State{state | ast: double_colon_ast(ident_var(state.name), choose_type(type, state.arg)),
                   meta: spec_type(state.arg)}
  end

  ### internal functions

  defp spec_optional(ast, %State{} = state) do
    %State{state | ast: nil, halt: true,
                   global_state: %{state.global_state | append_opts_ast: true,
                                                        opts: [ast | state.global_state.opts]}}
  end

  defp spec_meta(%State{arg: arg}) do
    %{command: Map.has_key?(arg, "command"), enum: Map.has_key?(arg, "enum")}
  end

  defp spec_type(%{"command" => _, "type" => "enum"}), do: :enum_command
  defp spec_type(%{"type" => "enum"}), do: :enum
  defp spec_type(_), do: :simple

  defp choose_type([v], arg) do
    {:list, [], [choose_type(v, arg)]}
  end
  defp choose_type(v, arg) when is_list(v) do
    {:{}, [], Enum.map(v, &(choose_type(&1, arg)))}
  end
  defp choose_type(v, %{"variadic" => true} = arg) do
    {ident(:variadic), [], [type(v, arg)]}
  end
  defp choose_type(v, arg) do
    type(v, arg)
  end

  defp type(t, _) when t in ["type", "string", "value"], do: dot(String, :t)

  defp type(t, _) when t in ["posix_time", "posix time"], do: ident_var(:posix_time)

  defp type("key", _), do: ident_var(:key)

  defp type("pattern", _), do: ident_var(:pattern)

  defp type("double", _), do: ident_var(:float)

  defp type("integer", _), do: ident_var(:integer)

  # makes spec for enums like: `:on | :off | :skip`
  defp type("enum", %{"enum" => enum}) do
    Enum.reduce(Enum.reverse(enum), nil, fn
      # fix for `migrate` command
      ("\"\"", acc) ->
        acc

      ("key", acc) ->
        type_or(ident_var(:key), acc)

      ("EX seconds", acc) ->
        type_or({:ex, ident(:integer)}, acc)

      ("PX milliseconds", acc) ->
        type_or({:px, ident(:integer)}, acc)

      (v, acc) ->
        type_or(ident(v), acc)
    end)
  end

  defp type_or(left, nil) do
    left
  end
  defp type_or(left, right) do
    {:|, [], [left, right]}
  end
end
