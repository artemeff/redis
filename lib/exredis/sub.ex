defmodule Exredis.Sub do
  @moduledoc """
  Subscribe functions for exredis
  """

  @type reconnect  :: :no_reconnect | integer
  @type max_queue  :: :infinity | integer
  @type behaviour  :: :drop | :exit
  @type start_link :: {:ok, pid} | {:error, term}

  @doc """
  Connect to the Redis server for subscribe to a channel

  * `start_link`
  * `start_link("127.0.0.1", 6379)`
  * `start_link("127.0.0.1", 6379, "with_password")`
  """
  @spec start_link(binary, integer, binary, reconnect, max_queue, behaviour) :: start_link
  def start_link(host, port, password \\ "",
            reconnect \\ :no_reconnect, max_queue \\ :infinity,
            behaviour \\ :drop), do:
    :eredis_sub.start_link(String.to_char_list(host), port, String.to_char_list(password), reconnect, max_queue, behaviour)


  def start_link do
    config = Exredis.Config.fetch_env

    :eredis_sub.start_link(String.to_char_list(config.host), config.port, String.to_char_list(config.password), config.reconnect, config.max_queue, config.behaviour)
  end

  @doc false
  @spec start(binary, integer, binary, reconnect, max_queue, behaviour) :: pid
  def start(host, port, password,
            reconnect, max_queue,
            behaviour) do
    IO.write :stderr, "warning: Exredis.Sub.start/6 is deprecated\n" <>
      Exception.format_stacktrace

    start_link(host, port, password, reconnect, max_queue, behaviour)
    |> elem(1)
  end
  @doc false
  @spec start :: pid
  def start do
    IO.write :stderr, "warning: Exredis.Sub.start/0 is deprecated\n" <>
      Exception.format_stacktrace

    config = Exredis.Config.fetch_env

    start_link(config.host, config.port, config.password, config.reconnect, config.max_queue, config.behaviour)
    |> elem(1)
  end

  @doc """
  Connect to the Redis server for subscribe to a channel using a connection string:

  * `start_using_connection_string("redis://user:password@127.0.0.1:6379/0")`
  * `start_using_connection_string("redis://127.0.0.1:6379")`

  The database number is ignored.

  Returns the pid of the connected client.
  """
  @spec start_using_connection_string(binary, reconnect, max_queue, behaviour) :: pid
  def start_using_connection_string(connection_string \\ "redis://127.0.0.1:6379",
        reconnect \\ :no_reconnect, max_queue \\ :infinity,
        behaviour \\ :drop) do
    config = Exredis.Config.parse(connection_string)
    start_link(config.host, config.port, config.password, reconnect, max_queue, behaviour) |> elem(1)
  end


  @doc """
  Disconnect from the Redis server:

  * `stop(client)`

  Client is a pid getting from start command
  """
  @spec stop(pid) :: :ok
  def stop(client), do:
    :eredis_sub.stop(client)

  @doc """
  Subscribe to a channel

  * `subscribe(client, "some_channel", fn(msg) -> ... end)`
  """
  @spec subscribe(pid, binary, term) :: any
  def subscribe(client, channel, term) do
    spawn_link fn ->
      :eredis_sub.controlling_process client
      :eredis_sub.subscribe client, List.wrap(channel)
      receiver(client, term)
    end
  end

  @doc """
  Subscribe to a channel by pattern

  * `psubscribe(client, "some_channel_*", fn(msg) -> ... end)`
  """
  @spec psubscribe(pid, binary, term) :: any
  def psubscribe(client, channel, term) do
    spawn_link fn ->
      :eredis_sub.controlling_process client
      :eredis_sub.psubscribe client, List.wrap(channel)
      receiver(client, term)
    end
  end

  @spec ack_message(pid) :: any
  defp ack_message(client) when is_pid(client), do:
    :eredis_sub.ack_message(client)

  @spec receiver(pid, term) :: any
  defp receiver(pid, callback) do
    receive do
      msg ->
        ack_message(pid)
        callback.(msg)
        receiver(pid, callback)

    end
  end
end
