Code.require_file "test_helper.exs", __DIR__

defmodule Pi do
  use Exredis

  # set/get
  def get, do: start |> query ["GET", "Pi"]
  def set, do: start |> query ["SET", "Pi", "3.14"]
end

defmodule ExredisTest do
  use ExUnit.Case, async: true

  # clear all redis keys
  setup_all do
    client = Exredis.start

    Exredis.query client, ["FLUSHALL"]
    Exredis.stop client
  end

  test "mixin" do
    assert Pi.set == "OK"
    assert Pi.get == "3.14"
  end

  test "connect / disconnect" do
    client = Exredis.start
    assert is_pid(client)

    status = Exredis.stop(client)
    assert status == :ok
  end

  test "SET / GET" do
    client = Exredis.start

    status = Exredis.query(client, ["SET", "FOO", "BAR"])
    assert status == "OK"

    status = Exredis.query(client, ["GET", "FOO"])
    assert status == "BAR"
  end

  test "MSET / MGET" do
    values = ["key1", "value1", "key2", "value2", "key3", "value3"]
    client = Exredis.start

    status = Exredis.query(client, ["MSET" | values])
    assert status == "OK"

    values = Exredis.query(client, ["MGET" | ["key1", "key2", "key3"]])
    assert values == ["value1", "value2", "value3"]
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
