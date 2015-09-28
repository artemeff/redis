defmodule Exredis.Script do
  defmacro defredis_script(name, file_path: file_path) do
    case File.read(file_path) do
      {:ok, content} -> quote do: defredis_script(unquote(name), unquote(content))
      _ -> :erlang.error "Script file is missing at #{file_path}"
    end
  end
  defmacro defredis_script(name, script) do
    script_sha = :crypto.hash(:sha, script) |> Base.encode16
    quote bind_quoted: [script_sha: script_sha, name: name, script: script] do
      def unquote(name)(client, keys \\ [], argv \\ []) do
        query_args = [length(keys)] ++ keys ++ argv
        case Exredis.query client, ["EVALSHA", unquote(script_sha)] ++ query_args do
          <<"NOSCRIPT", _ :: binary>> -> 
            load_script client, unquote(script)
            unquote(name)(client, keys, argv)
          reply -> reply
        end
      end
    end
  end

  def load_script(client, script) do
    case Exredis.query client, ["SCRIPT", "LOAD", script] do
      <<"ERR", error :: binary>> ->
        throw error
      reply -> 
        reply
    end
  end
end
