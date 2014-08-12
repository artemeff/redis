defmodule Exredis.ConnectionString do
  defmodule Config do
    defstruct host: nil, port: nil, password: nil
  end

  def parse(connection_string) do
    connection_string
      |> extract_auth_and_path
      |> convert_to_config
  end

  defp extract_auth_and_path(connection_string) do
    connection_string
      |> String.split("/")
      |> Enum.at(-1)
      |> String.split("@")
  end

  defp convert_to_config([ path ]) do
    [ host, port ] = parse_host_and_port(path)
    password = ""
    %Config{ host: host, port: port, password: password }
  end

  defp convert_to_config([ auth, path ]) do
    [ host, port ] = parse_host_and_port(path)
    password = parse_password(auth)
    %Config{ host: host, port: port, password: password }
  end

  defp parse_host_and_port(path) do
    [ host, port ] = path |> String.split(":")
    [ host, String.to_integer(port) ]
  end

  defp parse_password(auth) do
    [ _user, password ] = auth |> String.split(":")
    password
  end
end
