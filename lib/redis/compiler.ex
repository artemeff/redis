defmodule Redis.Compiler do
  @moduledoc false

  alias Redis.Compiler.AST

  defmacro __using__(_opts \\ []) do
    {commands, _} = Code.eval_string(read_commands())

    quote do
      alias Redis.Compiler.Types, as: T

      @typedoc "Redis key, extracted into separate type to support variadic arguments"
      @type key :: String.t

      @typedoc "Unix timestamp in seconds"
      @type posix_time :: non_neg_integer

      @typedoc "Redis pattern"
      @type pattern :: String.t

      @typedoc "Variadic argument, when argument values count should equals `t:key/0` count in command"
      @type variadic(value) :: list(value)

      unquote(Enum.map(commands, &define_command/1))
    end
  end

  defp define_command({command, meta}) do
    arguments = Map.get(meta, "arguments")

    spec = Redis.Compiler.Spec.make(command, arguments)
    args = Redis.Compiler.Arguments.make(arguments)
    func = Redis.Compiler.Function.make(arguments)
    docs = Redis.Compiler.Documentation.make(meta)

    AST.block(docs ++ [
      AST.at(:spec, spec),
      define(command, args, func)
    ])
  end

  defp define(command, args, func) do
    {:def, [],
      [
        {AST.ident(command), [], args},
        [do: [command | func]]
      ]}
  end

  defp read_commands do
    [:code.priv_dir(:redis), "commands.bin"]
    |> Path.join()
    |> File.read!()
    |> :zlib.gunzip()
  end
end
