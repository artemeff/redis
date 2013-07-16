defmodule Exredis.Sub do
  @moduledoc """
  Subscribe functions for exredis
  """

  import Exredis, only: [query: 2]

  @doc """
  Connect to the Redis server for subscribe to the channel

  * `start`
  * `start('127.0.0.1', 6379)`

  IP should be a list - single quotes instead of double
  """
  def start(host // '127.0.0.1', port // 6379, password // '',
            reconnect_sleep // :no_reconnect, max_queue_size // :infinity, queue_behaviour // :drop)
      when is_list(host) and is_integer(port) do
    
    :eredis_sub.start_link(host, port, password, reconnect_sleep, max_queue_size, queue_behaviour) |> elem 1
  end

  @doc """
  Disconnect from the Redis server:

  `stop client`

  Client is a pid getting from start command
  """
  def stop(client) when is_pid(client), do: :eredis_sub.stop(client)

  @doc """
  Subscribe to a channel

  `subscribe client, "some_channel"`
  """
  @doc """
  Subscribe
  """
  def subscribe(client, channel, func, pid)
      when is_pid(client) and is_binary(channel) and is_function(func) and is_pid(pid) do

    receiver = spawn_link fn ->
      :eredis_sub.controlling_process client
      :eredis_sub.subscribe client, [channel]
      func.(client, pid)
    end

    receiver
  end

  #def subscribe(client, channel) when is_pid(client) and is_binary(channel),
  #  do: :eredis_sub.subscribe(client, channel)

  @doc """
  Publish to the channel

  `publish client, "some_channel", "Hello World!"`
  """
  def publish(client, channel, message) when is_pid(client) and is_binary(channel) and is_binary(message),
    do: query(client, ["PUBLISH", channel, message])

  @doc false
  def ack_message(client) when is_pid(client), do: :eredis_sub.ack_message(client)

end
