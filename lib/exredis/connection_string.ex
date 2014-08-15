defmodule Exredis.ConnectionString do
  defmodule Config do
    defstruct host: nil, port: nil, password: nil, db: nil
  end

  def parse(connection_string) do
    uri = URI.parse(connection_string)
    
    %Config{
      host:     uri.host |> String.to_char_list,
      port:     uri.port,
      password: uri.userinfo |> parse_password,
      db:       uri.path |> parse_db
    }
  end

  defp parse_db(nil), do: 0
  defp parse_db(path) do
    path |> String.split("/") |> Enum.at(1) |> String.to_integer
  end

  defp parse_password(nil), do: ''
  defp parse_password(auth) do
    auth |> String.split(":") |> Enum.at(1) |> String.to_char_list
  end
end
