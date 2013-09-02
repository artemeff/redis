Code.require_file "test_helper.exs", __DIR__

defmodule Pi do
  use Exredis

  # set/get
  def get, do: start |> query ["GET", "Pi"]
  def set, do: start |> query ["SET", "Pi", "3.14"]
end

defmodule ExredisTest do
  use ExUnit.Case, async: true

  setup do
    client = Exredis.start

    # clean up database
    client |> Exredis.query ["FLUSHALL"]
    client |> Exredis.query ["SET", "key", "value"]

    { :ok, [c: client] }
  end

  teardown ctx, do:
    ctx[:c] |> Exredis.stop


  test "mixin Pi.get", ctx do
    ctx[:c] |> Exredis.query ["SET", "Pi", "3.14"]

    assert Pi.get == "3.14"
  end

  test "mixin Pi.set", ctx do
    Pi.set

    assert (ctx[:c] |> Exredis.query ["GET", "Pi"]) == "3.14"
  end

  test "connect" do
    assert Exredis.start |> is_pid
  end

  test "connect, erlang way" do
    { :ok, pid } = Exredis.start_link

    assert pid |> is_pid
  end

  test "disconnect" do
    assert (Exredis.start |> Exredis.stop) == :ok
  end

  test "set returns OK", ctx do
    assert (ctx[:c] |> Exredis.query ["SET", "foo", "bar"]) == "OK"
  end

  test "set works", ctx do
    ctx[:c] |> Exredis.query ["SET", "foo", "bar"]

    assert (ctx[:c] |> Exredis.query ["GET", "foo"]) == "bar"
  end

  test "get", ctx do
    assert (ctx[:c] |> Exredis.query ["GET", "key"]) == "value"
  end

  test "mset returns OK", ctx do
    values = ["key1", "value1", "key2", "value2"]

    assert (ctx[:c] |> Exredis.query ["MSET" | values]) == "OK"
  end

  test "mset works", ctx do
    ctx[:c] |> Exredis.query ["MSET" | ["key1", "value1", "key2", "value2"]]

    values = ctx[:c] |> Exredis.query ["MGET" | ["key1", "key2"]]

    assert values == ["value1", "value2"]
  end

  test "transactions" do
    client = Exredis.start

    status = Exredis.query(client, ["MULTI"])
    assert status == "OK"

    status = Exredis.query(client, ["SET", "foo", "bar"])
    assert status == "QUEUED"

    status = Exredis.query(client, ["SET", "bar", "baz"])
    assert status == "QUEUED"

    status = Exredis.query(client, ["EXEC"])
    assert status == ["OK", "OK"]

    values = Exredis.query(client, ["MGET" | ["foo", "bar"]])
    assert values == ["bar", "baz"]
  end

  test "pipelining" do
    query  = [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]]
    client = Exredis.start

    status = Exredis.query_pipe(client, query)
    assert status == [ok: "OK", ok: "1", ok: "2"]
  end
end
