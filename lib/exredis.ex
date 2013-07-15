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

  @doc """
  Connect to the Redis server:

  * `start`
  * `start('127.0.0.1', 6379)`

  IP should be a list - single quotes instead of double
  """
  def start(host // '127.0.0.1', port // 6379, database // 0,  password // '', reconnect_sleep // :no_reconnect)
    when is_list(host) and is_integer(port) and is_integer(database),
    do: :eredis.start_link(host, port, database, password, reconnect_sleep) |> elem 1

  @doc """
  Disconnect from the Redis server:

  `stop client`

  Client is a pid getting from start command
  """
  def stop(client) when is_pid(client), do: :eredis.stop(client)

  @doc """
  Make query

  * `query client, ["SET", "foo", "bar"]`
  * `query client, ["GET", "foo"]`
  * `query client, ["MSET" | ["key1", "value1", "key2", "value2", "key3", "value3"]]`
  * `query client, ["MGET" | ["key1", "key2", "key3"]]`

  See more commands in official Redis documentation
  """
  def query(client, command) when is_pid(client) and is_list(command),
    do: :eredis.q(client, command) |> elem 1

  @doc """
  Pipeline query
  """
  def query_pipe(client, command) when is_pid(client) and is_list(command),
    do: :eredis.qp(client, command)

  @doc """
  Subscribe to a channel

  `subscribe client, "some_channel"`
  """
  def subscribe(client, channel) when is_pid(client) and is_binary(channel),
    do: :eredis_sub.subscribe(client, channel)

  @doc """
  Publish to the channel

  `publish client, "some_channel", "Hello World!"`
  """
  def publish(client, channel, message) when is_pid(client) and is_binary(channel) and is_binary(message),
    do: query(client, ["PUBLISH", channel, message])

end
