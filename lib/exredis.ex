defmodule Exredis do
  @moduledoc """
  Redis client for Elixir
  """

  @type reconnect_sleep :: :no_reconnect | integer
  @type start_link      :: {:ok, pid} | {:error, term}

  @doc """
  Connects to the Redis server using a connection string:

  * `start_using_connection_string("redis://user:password@127.0.0.1:6379/0")`
  * `start_using_connection_string("redis://127.0.0.1:6379")`

  Returns the pid of the connected client.
  """
  @spec start_using_connection_string(binary, :no_reconnect | integer) :: pid
  def start_using_connection_string(connection_string \\ "redis://127.0.0.1:6379", reconnect_sleep \\ :no_reconnect)  do
    config = Exredis.Config.parse(connection_string)
    start_link(config.host, config.port, config.db, config.password, reconnect_sleep) |> elem(1)
  end

  @doc false
  @spec start(binary, integer, integer, binary, :no_reconnect | integer) :: pid
  def start(host, port, database \\ 0,
            password \\ "", reconnect_sleep \\ :no_reconnect) do
    IO.write :stderr, "warning: Exredis.start/5 is deprecated\n" <>
      Exception.format_stacktrace

    start_link(host, port, database, password, reconnect_sleep)
    |> elem(1)
  end


  @doc false
  @spec start :: pid
  def start do
    IO.write :stderr, "warning: Exredis.start/0 is deprecated\n" <>
      Exception.format_stacktrace

    config = Exredis.Config.fetch_env
    start_link(config.host, config.port, config.db, config.password, config.reconnect)
    |> elem(1)
  end

  @doc """
  Allows poolboy to connect to this by passing a list of args
  """
  def start_link(system_args) when is_list(system_args) do
    system_args = Enum.map(system_args, fn{k,v} ->
      if is_binary(v) do
        {k, String.to_char_list(v)}
      else
        {k,v}
      end
    end)
    :eredis.start_link(system_args)
  end

  @doc """
  Connects to the Redis server, Erlang way:

  * `start_link("127.0.0.1", 6379)`

  Returns a tuple `{:ok, pid}`.
  """
  @spec start_link(binary, integer, integer, binary, reconnect_sleep) :: start_link
  def start_link(host, port, database \\ 0,
                 password \\ "", reconnect_sleep \\ :no_reconnect) when is_binary(host) do
    :eredis.start_link(String.to_char_list(host), port, database, String.to_char_list(password), reconnect_sleep)
  end

  @doc """
  Connects to the Redis server, Erlang way:

  * `start_link`

  Returns a tuple `{:ok, pid}`.
  """
  @spec start_link :: start_link
  def start_link do
    config = Exredis.Config.fetch_env
    :eredis.start_link(String.to_char_list(config.host), config.port, config.db, String.to_char_list(config.password), config.reconnect)
  end

  @doc """
  Disconnects from the Redis server:

  `stop client`

  `client` is a `pid` like the one returned by `Exredis.start`.
  """
  @spec stop(pid) :: :ok
  def stop(client), do:
    client |> :eredis.stop

  @doc """
  Performs a query with the given arguments on the connected `client`.

  * `query(client, ["SET", "foo", "bar"])`
  * `query(client, ["GET", "foo"])`
  * `query(client, ["MSET" | ["k1", "v1", "k2", "v2", "k3", "v3"]])`
  * `query(client, ["MGET" | ["k1", "k2", "k3"]])`

  See all the available commands in the [official Redis
  documentation](http://redis.io/commands).
  """
  @spec query(pid, list) :: any
  def query(client, command) when (is_pid(client) or is_atom(client)) and is_list(command), do:
    client |> :eredis.q(command) |> elem(1)

  @doc """

  Performs a query with the given arguments on the connected `client`.

  * `query(client, ["SET", "foo", "bar"], 100)`

  See all the available commands in the [official Redis
  documentation](http://redis.io/commands).
  """
  @spec query(pid, list, Integer) :: any
  def query(client, command, timeout) when is_pid(client) and is_list(command) and is_integer(timeout), do:
    client |> :eredis.q(command, timeout) |> elem(1)

  @doc """
  Performs a pipeline query, executing the list of commands.

      query_pipe(client, [["SET", :a, "1"],
                          ["LPUSH", :b, "3"],
                          ["LPUSH", :b, "2"]])
  """
  @spec query_pipe(pid, [list]) :: any
  def query_pipe(client, command) when (is_pid(client) or is_atom(client)) and is_list(command), do:
    client |> :eredis.qp(command) |> Enum.map(&elem(&1, 1))
end
