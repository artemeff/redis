defmodule Exredis.Config do
  defmodule Config do
    defstruct host: nil, port: nil, password: nil, db: nil, reconnect: nil, max_queue: nil, behaviour: nil
  end

  @default_config %{
    host: "127.0.0.1",
    port: 6379,
    password: "",
    db: 0,
    reconnect: :no_reconnect,
    max_queue: :infinity,
    behaviour: :drop
  }

  def settings, do: [:host, :port, :password, :db, :reconnect, :max_queue, :behaviour]

  def fetch_env do
    uri_config = Application.get_env(:exredis, :url)
      |> parse
      |> Map.from_struct
      |> filter_nils
    application_config = settings
      |> Enum.reduce(%{}, fn (key, config) -> config |> load_config_key(key) end)
      |> filter_nils

    config = @default_config
      |> Map.merge(uri_config)
      |> Map.merge(application_config)
      |> parse_port
    struct(Config, config)
  end
  defp parse_port(m) do
    n = case is_integer(m.port) do
      true -> 
        m.port 
      _ -> 
        {i, _} = Integer.parse(m.port)
        i
    end
    %{m | :port=>n}

  end

  def parse(nil), do: %Config{}
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

  defp load_config_key(config, key) do
    r = Application.get_env(:exredis, key)
    value = case r do
      {:system, name} -> System.get_env(name)
      _               -> r
    end

    Dict.put(config, key, value)
  end

  defp filter_nils(map) do
    map
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
  end
end
