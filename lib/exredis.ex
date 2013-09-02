defmodule Exredis do
  @moduledoc """
  Redis client for Elixir
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Exredis
    end
  end

  @type reconnect_sleep :: :no_reconnect | integer
  @type start_link      :: { :ok, pid } | { :error, term }

  @doc """
  Connect to the Redis server, erlang way:

  * `start`
  * `start('127.0.0.1', 6379)`

  Returns tuple { :ok, pid }
  """
  @spec start_link(list, integer, integer, list, reconnect_sleep) :: start_link
  def start_link(host // '127.0.0.1', port // 6379, database // 0,  password // '', reconnect_sleep // :no_reconnect),
    do: :eredis.start_link(host, port, database, password, reconnect_sleep)

  @doc """
  Connect to the Redis server:

  * `start`
  * `start('127.0.0.1', 6379)`

  Returns pid of the connected client
  """
  @spec start(list, integer, integer, list, :no_reconnect | integer) :: pid
  def start(host // '127.0.0.1', port // 6379, database // 0,  password // '', reconnect_sleep // :no_reconnect),
    do: :eredis.start_link(host, port, database, password, reconnect_sleep) |> elem 1

  @doc """
  Disconnect from the Redis server:

  `stop client`

  Client is a pid getting from start command
  """
  @spec stop(pid) :: :ok
  def stop(client), do: :eredis.stop(client)

  @doc """
  Make query

  * `query(client, ["SET", "foo", "bar"])`
  * `query(client, ["GET", "foo"])`
  * `query(client, ["MSET" | ["key1", "value1", "key2", "value2", "key3", "value3"]])`
  * `query(client, ["MGET" | ["key1", "key2", "key3"]])`

  See more commands in official Redis documentation
  """
  @spec query(pid, list) :: any
  def query(client, command) when is_pid(client) and is_list(command),
    do: :eredis.q(client, command) |> elem 1

  @doc """
  Pipeline query

  `query_pipe(client, [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]])`
  """
  @spec query_pipe(pid, list) :: any
  def query_pipe(client, command) when is_pid(client) and is_list(command),
    do: :eredis.qp(client, command)

end
