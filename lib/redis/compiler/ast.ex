defmodule Redis.Compiler.AST do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      import Redis.Compiler.AST
      alias Redis.Compiler.AST.State
    end
  end

  defmodule State do
    @moduledoc false

    defstruct [:arg, :global_state, name: nil, ast: nil, halt: false, meta: nil]

    def new(arg, global_state \\ nil) do
      %__MODULE__{arg: arg, global_state: global_state}
    end

    def walk(%__MODULE__{halt: true} = state, _fun) do
      state
    end
    def walk(%__MODULE__{} = state, fun) do
      fun.(state)
    end

    def finalize(%__MODULE__{ast: nil, global_state: global_state}) do
      {:skip, global_state}
    end
    def finalize(%__MODULE__{ast: ast, global_state: global_state}) do
      {:append, ast, global_state}
    end
  end

  def types_func(name, args) do
    {{:., [], [{:__aliases__, [alias: false], [:T]}, name]}, [], args}
  end

  def ident(name) when is_binary(name) do
    name |> String.downcase |> String.replace(~r/[-\:\s]/, "_") |> String.to_atom
  end
  def ident(name) when is_atom(name) do
    name
  end

  def ident_var(name, meta \\ [], context \\ Elixir) do
    {fix_reserved_words(ident(name)), meta, context}
  end

  def pipe(left, right) do
    {:|>, [context: Elixir, import: Kernel], [left, right]}
  end

  def block(contents) when is_list(contents) do
    {:__block__, [], contents}
  end

  def optional(left, default \\ nil) do
    {:\\, [], [left, default]}
  end

  def at(name, contents) do
    {:@, [context: Elixir], [{name, [context: Elixir], [contents]}]}
  end

  def dot(mod, func) do
    {{:., [], [{:__aliases__, [alias: false], [mod]}, func]}, [], []}
  end

  def double_colon_ast(left, right) do
    {:::, [], [left, right]}
  end

  defp fix_reserved_words(:end), do: :end_
  defp fix_reserved_words(v), do: v
end
