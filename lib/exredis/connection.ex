defmodule Exredis.Connection do
  @moduledoc """
  A GenServer used to manage a Redis connection in a fault-tolerant fashion.
  """

  use GenServer

  @doc """
  Starts a supervised process to manage all Redis requests for a given connection.
  The process is registered with a given name so it can be restarted by its supervisor.

  `start_link(:myredis_proc, :myredis_conn, "redis://example.com:6379/0")`

  This is often called indirectly by registering a worker in the supervision tree when
  bootstrapping an application:

  `worker(Exredis.Connection, [:myredis_proc, :myredis_conn, "redis://example.com:6379/0"])`

  Returns a tuple containing the status and pid of the linked process.
  """
  def start_link(proc_name, conn_name, uri) do
    GenServer.start_link(__MODULE__, [conn_name, uri], name: proc_name)
  end

  @doc """
  Invoked when the server is started, e.g. by calling `start_link/3`.
  It starts and registers a linked process that acts as a Redis client for a given URI.
  This is not meant to be called directly.
  """
  def init(state = [conn_name, uri]) do
    Process.flag(:trap_exit, true)

    uri
    |> Exredis.start_using_connection_string
    |> register_redis(conn_name)

    Process.flag(:trap_exit, false)

    {:ok, state}
  end

  @doc """
  Retrieves the Redis client registered with the given name:

  `client name`

  Returns the `pid` of the client.
  """
  def client(conn_name), do: Process.whereis(conn_name)

  defp register_redis({:connection_error, error}, _conn_name) do
    raise "Could not connect to Redis with error: #{inspect(error)}"
  end
  defp register_redis(pid, conn_name) do
    pid |> Process.register(conn_name)
  end
end
