Code.require_file "test_helper.exs", __DIR__

defmodule ExredisTest do
  use ExUnit.Case, async: true

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

  # TODO fix test
  test "pipelining" do
    query  = [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]]
    client = Exredis.start

    status = Exredis.query_pipe(client, query)
    assert status == [ok: "OK", ok: "1", ok: "2"]
  end

  test "pub/sub" do
    client = Exredis.start

    status = Exredis.subscribe(client, "foo")
    assert status == :ok

    status = Exredis.publish(client, "foo", "bar")
    assert status == "0"
  end
end
