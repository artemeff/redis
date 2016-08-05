Code.require_file "test_helper.exs", __DIR__

defmodule ConnectionTest do
  use ExUnit.Case

  alias Exredis.Connection

  setup do
    pid = Connection.start_link(:proc_name, :conn_name, "redis://127.0.0.1:6379/0") |> elem(1)
    {:ok, pid: pid}
  end

  test "start_link/2 registers processes with given proc name and conn name", %{pid: pid} do
    assert pid |> is_pid
    assert Process.whereis(:proc_name)
    assert Process.whereis(:conn_name)
  end

  test "client/1 retrieves the Redis client registered with the given name", %{pid: _pid} do
    assert Connection.client(:conn_name)
  end
end
