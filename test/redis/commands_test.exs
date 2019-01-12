defmodule Redis.CompilerTest do
  use ExUnit.Case, async: true

  test "#set" do
    assert str(Redis.set("key", "value"))
        == "SET key value"

    assert str(Redis.set("key", "value", []))
        == "SET key value"

    assert str(Redis.set("key", "value", expiration: {:ex, 1_000}, condition: :nx))
        == "SET key value EX 1000 NX"

    assert str(Redis.set("key", "value", expiration: {:px, 1_000_0000}, condition: :xx))
        == "SET key value PX 10000000 XX"

    assert str(Redis.set("key", "value", [:xx, expiration: {:px, 1_000_0000}]))
        == "SET key value PX 10000000 XX"
  end

  test "#mget" do
    assert str(Redis.mget("key1"))
        == "MGET key1"

    assert str(Redis.mget(["key1"]))
        == "MGET key1"

    assert str(Redis.mget(["key1", "key2", "key3"]))
        == "MGET key1 key2 key3"
  end

  test "#mset" do
    assert str(Redis.mset([{"key1", "value1"}, {"key2", "value2"}]))
        == "MSET key1 value1 key2 value2"

    assert_raise(ArgumentError, ~s(key_value should be tuple of 2 elements, but got ["key1"]), fn ->
      Redis.mset([["key1"]])
    end)

    assert_raise(ArgumentError, ~s(key_value should be tuple of 2 elements, but got "key1"), fn ->
      Redis.mset(["key1"])
    end)

    assert_raise(ArgumentError, ~s(key_value should be tuple of 2 elements, but got "key1"), fn ->
      Redis.mset("key1")
    end)
  end

  test "#hmget" do
    assert str(Redis.hmget("key", "field"))
        == "HMGET key field"

    assert str(Redis.hmget("key", ["field1"]))
        == "HMGET key field1"

    assert str(Redis.hmget("key", ["field1", "field2"]))
        == "HMGET key field1 field2"
  end

  test "#hmset" do
    assert str(Redis.hmset("key", [{"field1", "value1"}]))
        == "HMSET key field1 value1"

    assert str(Redis.hmset("key", [{"field1", "value1"}, {"field2", "value2"}]))
        == "HMSET key field1 value1 field2 value2"

    assert_raise(ArgumentError, ~s(field_value should be tuple of 2 elements, but got "field"), fn ->
      Redis.hmset("key", "field")
    end)

    assert_raise(ArgumentError, ~s(field_value should be tuple of 2 elements, but got "field"), fn ->
      Redis.hmset("key", ["field", "value"])
    end)

    assert_raise(ArgumentError, ~s(field_value should be tuple of 2 elements, but got ["field"]), fn ->
      Redis.hmset("key", [["field"]])
    end)
  end

  test "#bitcount" do
    assert str(Redis.bitcount("key"))
        == "BITCOUNT key"

    assert str(Redis.bitcount("key", start_end: {1, 2}))
        == "BITCOUNT key 1 2"
  end

  test "#bitfield" do
    assert str(Redis.bitfield("key", get: {"type", "offset"}, set: {"type", "offset", "value"},
                                     incrby: {"type", "offset", "increment"}, overflow: :wrap))
        == "BITFIELD key GET type offset SET type offset value INCRBY type offset increment OVERFLOW WRAP"

    assert str(Redis.bitfield("key", incrby: {"type", "offset", "increment"}, overflow: :wrap))
        == "BITFIELD key INCRBY type offset increment OVERFLOW WRAP"

    assert_raise(ArgumentError, "overflow accepts :fail, :sat, :wrap, but :what provided", fn ->
      Redis.bitfield("key", overflow: :what)
    end)

    assert_raise(ArgumentError, ~s(get should be tuple of 2 elements, but got "what"), fn ->
      Redis.bitfield("key", get: "what")
    end)

    assert_raise(ArgumentError, ~s(get should be tuple of 2 elements, but got ["what"]), fn ->
      Redis.bitfield("key", get: ["what"])
    end)
  end

  test "#bitpos" do
    assert str(Redis.bitpos("key", 1))
        == "BITPOS key 1"

    assert str(Redis.bitpos("key", 1, start: 2))
        == "BITPOS key 1 2"

    assert str(Redis.bitpos("key", 1, start: 2, end: 3))
        == "BITPOS key 1 2 3"
  end

  test "#zunionstore" do
    assert str(Redis.zunionstore("dest", 1, ["key1", "key2"]))
        == "ZUNIONSTORE dest 1 key1 key2"

    assert str(Redis.zunionstore("dest", 1, ["key"], []))
        == "ZUNIONSTORE dest 1 key"

    assert str(Redis.zunionstore("dest", 1, ["key1", "key2"], weights: ["weight"]))
        == "ZUNIONSTORE dest 1 key1 key2 WEIGHTS weight"

    assert_raise(ArgumentError, "key required", fn ->
      Redis.zunionstore("dest", 1, [])
    end)
  end

  test "#migrate" do
    assert str(Redis.migrate("host", "port", "key1", "destination-db", "timeout"))
        == "MIGRATE host port key1 destination-db timeout"

    assert str(Redis.migrate("host", "port", "key2", "destination-db", "timeout"))
        == "MIGRATE host port key2 destination-db timeout"

    assert str(Redis.migrate("host", "port", "key2", "destination-db", "timeout", [copy: :copy, replace: :replace, keys: ["key1", "key2"]]))
        == "MIGRATE host port key2 destination-db timeout COPY REPLACE KEYS key1 key2"

    assert str(Redis.migrate("host", "port", "key2", "destination-db", "timeout", [:copy, :replace, keys: ["key1", "key2"]]))
        == "MIGRATE host port key2 destination-db timeout COPY REPLACE KEYS key1 key2"
  end

  test "#restore" do
    assert str(Redis.restore("key", "ttl", "srlzd-value"))
        == "RESTORE key ttl srlzd-value"

    assert str(Redis.restore("key", "ttl", "srlzd-value", [:replace]))
        == "RESTORE key ttl srlzd-value REPLACE"

    assert str(Redis.restore("key", "ttl", "srlzd-value", replace: :replace))
        == "RESTORE key ttl srlzd-value REPLACE"

    assert_raise(ArgumentError, "replace accepts :replace, but :what provided", fn ->
      Redis.restore("key", "ttl", "srlzd-value", replace: :what)
    end)
  end

  test "#script_debug" do
    assert str(Redis.script_debug(:sync))
        == "SCRIPT DEBUG SYNC"

    assert str(Redis.script_debug(:yes))
        == "SCRIPT DEBUG YES"

    assert str(Redis.script_debug(:no))
        == "SCRIPT DEBUG NO"

    assert_raise(ArgumentError, "mode accepts :no, :sync, :yes, but :what provided", fn ->
      Redis.script_debug(:what)
    end)
  end

  test "#shutdown" do
    assert str(Redis.shutdown)
        == "SHUTDOWN"

    assert str(Redis.shutdown([:save]))
        == "SHUTDOWN SAVE"

    assert str(Redis.shutdown([:nosave]))
        == "SHUTDOWN NOSAVE"

    assert_raise(ArgumentError, "save_mode expects list of options, but :what provided", fn ->
      Redis.shutdown(:what)
    end)
  end

  test "#client_kill" do
    assert str(Redis.client_kill(ip_port: "ip:port", type: :master, addr: "asd:qwe", skipme: :yes, id: "asd"))
        == "CLIENT KILL ip:port ID asd TYPE master ADDR asd:qwe SKIPME yes"

    assert str(Redis.client_kill(ip_port: "ip:port", type: :pubsub, skipme: :no))
        == "CLIENT KILL ip:port TYPE pubsub SKIPME no"

    assert_raise(ArgumentError, "type accepts :master, :normal, :pubsub, :slave, but :what provided", fn ->
      Redis.client_kill(ip_port: "ip:port", type: :what)
    end)
  end

  test "#linsert" do
    assert str(Redis.linsert("key", :before, "pivot", "value"))
        == "LINSERT key BEFORE pivot value"

    assert str(Redis.linsert("key", :after, "pivot", "value"))
        == "LINSERT key AFTER pivot value"

    assert_raise(ArgumentError, "where accepts :after, :before, but :what provided", fn ->
      Redis.linsert("key", :what, "pivot", "value")
    end)
  end

  test "#georadiusbymember" do
    assert str(Redis.georadiusbymember("key", "member", "radius", :km))
        == "GEORADIUSBYMEMBER key member radius km"

    assert str(Redis.georadiusbymember("key", "member", "radius", :km, [withcoord: :withcoord, count: "1", order: :asc]))
        == "GEORADIUSBYMEMBER key member radius km WITHCOORD COUNT 1 ASC"

    assert str(Redis.georadiusbymember("key", "member", "radius", :km, [:asc, :withdist, :withcoord, count: "1", order: :asc]))
        == "GEORADIUSBYMEMBER key member radius km WITHCOORD WITHDIST COUNT 1 ASC"
  end

  defp str(v) do
    List.to_string(v)
  end
end
