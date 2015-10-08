defmodule Exredis.Config do
  defmodule Config do
    defstruct host: nil, port: nil, password: nil, db: nil, reconnect: nil, max_queue: nil, behaviour: nil
  end

	def fetch_env do
    %Config{
      host:     				Application.get_env(:exredis, :host) || "127.0.0.1",
      port:     				Application.get_env(:exredis, :port) || 6379,
      password: 				Application.get_env(:exredis, :password) || "",
      db:       				Application.get_env(:exredis, :db) || 0,
      reconnect:  Application.get_env(:exredis, :reconnect) || :no_reconnect,
      max_queue: 				Application.get_env(:exredis, :max_queue) || :infinity,
      behaviour:				Application.get_env(:exredis, :behaviour) || :drop
    }
	end

  def parse(connection_string) do
    uri = URI.parse(connection_string)

    %Config{
      host:     uri.host,
      port:     uri.port,
      password: uri.userinfo |> parse_password,
      db:       uri.path |> parse_db
    }
  end

  defp parse_db(nil), do: 0
  defp parse_db("/"), do: 0
  defp parse_db(path) do
    path |> String.split("/") |> Enum.at(1) |> String.to_integer
  end

  defp parse_password(nil), do: ""
  defp parse_password(auth) do
    auth |> String.split(":") |> Enum.at(1)
  end

end
