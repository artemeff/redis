defmodule Exredis.Sub do
  @moduledoc """
  Subscribe functions for exredis
  """

  import Exredis, only: [query: 2]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Exredis.Sub
      require Exredis.Sub
    end
  end

  @doc """
  Connect to the Redis server for subscribe to the channel

  * `start`
  * `start('127.0.0.1', 6379)`
  * `start('127.0.0.1', 6379, 'with_password')`

  IP should be a list - single quotes instead of double
  """
  def start(host // '127.0.0.1', port // 6379, password // '',
            reconnect_sleep // :no_reconnect, max_queue_size // :infinity,
            queue_behaviour // :drop) when is_list(host) and is_integer(port), do:

    :eredis_sub.start_link(host, port, password, reconnect_sleep, max_queue_size, queue_behaviour)
    |> elem 1

  @doc """
  Disconnect from the Redis server:

  * `stop(client)`

  Client is a pid getting from start command
  """
  def stop(client) when is_pid(client), do: :eredis_sub.stop(client)

  @doc """
  Subscribe to a channel

  * `subscribe(client, "some_channel", fn(msg) -> ... end)`
  """
  @spec subscribe(pid, binary, term) :: any
  defmacro subscribe(client, channel, term) do
    quote do
      client = unquote(client)
      channel = unquote(channel)
      term = unquote(term)

      spawn_link fn ->
        :eredis_sub.controlling_process client
        :eredis_sub.subscribe client, [channel]
        receiver(client, term)
      end
    end
  end

  @doc """
  Subscribe to a channel by pattern

  * `psubscribe(client, "some_channel_*", fn(msg) -> ... end)`
  """
  @spec psubscribe(pid, binary, term) :: any
  defmacro psubscribe(client, channel, term) do
    quote do
      client = unquote(client)
      channel = unquote(channel)
      term = unquote(term)

      spawn_link fn ->
        :eredis_sub.controlling_process client
        :eredis_sub.psubscribe client, [channel]
        receiver(client, term)
      end
    end
  end

  @doc """
  Publish to the channel, client should be started from
  regular exredis method: `Exredis.start`

  * `publish(client, "some_channel", "Hello World!")`
  """
  def publish(client, channel, message)
    when is_pid(client) and is_binary(channel) and is_binary(message), do:
    query(client, ["PUBLISH", channel, message])

  ##
  # Internal methods
  ##

  @doc false
  def ack_message(client) when is_pid(client), do:
    :eredis_sub.ack_message(client)

  @doc false
  def receiver(pid, callback) do
    receive do
      msg ->
        ack_message(pid)
        callback.(msg)
        receiver(pid, callback)
    end
  end
end
