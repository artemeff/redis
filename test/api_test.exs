Code.require_file "test_helper.exs", __DIR__

defmodule ApiMixin do
  import Exredis.Api

  def set(client), do:
    client |> set("key", "value")

  def get(client), do:
    client |> get("key")

end

defmodule ApiTest do
  use ExUnit.Case, sync: true
  alias Exredis, as: E
  alias Exredis.Api, as: R

  setup do
    {:ok, client} = E.start_link

    # clean up database and set test value
    client |> E.query(["FLUSHALL"])
    client |> E.query(["SET", "key", "value"])

    { :ok, [c: client] }
  end

  test "mixin", c do
    assert (c[:c] |> ApiMixin.set) == :ok
    assert (c[:c] |> ApiMixin.get) == "value"
  end

  ##
  # Keys
  ##

  test "del", c do
    assert (c[:c] |> R.del("key")) == 1
    assert (c[:c] |> R.del(["key1", "key2"])) == 0
    end

  test "keys", c do
    c[:c] |> R.flushall
    c[:c] |> R.mset(["k1", "v1", "k2", "v2"])

    assert length(c[:c] |> R.keys("k*")) == 2
  end

  test "pexpire", c do
    assert (c[:c] |> R.pexpire("key", "1500")) == 1
    assert (c[:c] |> R.pexpire("non-existing-key", "1500")) == 0
  end

  test "renamenx", c do
    assert (c[:c] |> R.renamenx("key", "new_key")) == 1
  end

  test "dump", c do
    assert is_binary(c[:c] |> R.dump("key")) == true
  end

  test "migrate", _c do
    # TODO
  end

  test "pexpireat", c do
    assert (c[:c] |> R.pexpireat("key", "1500")) == 1
    assert (c[:c] |> R.pexpireat("non-existing-key", "1500")) == 0
  end

  test "restore", _c do
    # TODO
  end

  test "exists", c do
    assert (c[:c] |> R.exists("key")) == 1
    assert (c[:c] |> R.exists("non-existing-key")) == 0
  end

  test "move", _c do
    # TODO
  end

  test "pttl", c do
    assert (c[:c] |> R.pttl("key")) == -1
  end

  test "sort", _c do
    # TODO
  end

  test "expire", c do
    assert (c[:c] |> R.expire("key", "1500")) == 1
    assert (c[:c] |> R.expire("non-existing-key", "1500")) == 0
  end

  test "object", _c do
    # TODO
  end

  test "randomkey", c do
    assert (c[:c] |> R.randomkey) == "key"
  end

  test "ttl", c do
    assert (c[:c] |> R.ttl("key")) == -1
  end

  test "expireat", c do
    assert (c[:c] |> R.expireat("key", "1293840000")) == 1
  end

  test "persist", c do
    assert (c[:c] |> R.persist("key")) == 0
  end

  test "rename", c do
    assert (c[:c] |> R.rename("key", "new_key")) == :ok
  end

  test "type", c do
    assert (c[:c] |> R.type("key")) == "string"
  end

  ##
  # Strigns
  ##

  test "append", c do
    assert (c[:c] |> R.append("mykey", "hello")) == 5
    assert (c[:c] |> R.append("mykey", " world")) == 11
    assert (c[:c] |> R.get("mykey")) == "hello world"
  end

  test "bitcount", c do
    assert (c[:c] |> R.set("mykey", "foobar")) == :ok
    assert (c[:c] |> R.bitcount("mykey")) == 26
    assert (c[:c] |> R.bitcount("mykey", 0, 0)) == 4
    assert (c[:c] |> R.bitcount("mykey", 1, 1)) == 6
  end

  test "decr", c do
    assert (c[:c] |> R.set("mykey", 10)) == :ok
    assert (c[:c] |> R.decr("mykey")) == 9
  end

  test "decrby", c do
    assert (c[:c] |> R.set("mykey", 10)) == :ok
    assert (c[:c] |> R.decrby("mykey", 5)) == 5
  end

  test "get", c do
    assert (c[:c] |> R.get("key")) == "value"
  end

  test "getbit", c do
    assert (c[:c] |> R.setbit("bitkey", 7, 1)) == 0
    assert (c[:c] |> R.getbit("bitkey", 0)) == 0
    assert (c[:c] |> R.getbit("bitkey", 7)) == 1
  end

  test "getrange", c do
    assert (c[:c] |> R.set("mykey", "This is a string")) == :ok
    assert (c[:c] |> R.getrange("mykey", 0, 3)) == "This"
    assert (c[:c] |> R.getrange("mykey", -3, -1)) == "ing"
    assert (c[:c] |> R.getrange("mykey", 0, -1)) == "This is a string"
    assert (c[:c] |> R.getrange("mykey", 10, 100)) == "string"
  end

  test "getset", c do
    assert (c[:c] |> R.set("mykey", "val")) == :ok
    assert (c[:c] |> R.getset("mykey", "new")) == "val"
    assert (c[:c] |> R.get("mykey")) == "new"
  end

  test "incr", c do
    assert (c[:c] |> R.set("mykey", 10)) == :ok
    assert (c[:c] |> R.incr("mykey")) == 11
    assert (c[:c] |> R.get("mykey")) == "11"
  end

  test "incrby", c do
    assert (c[:c] |> R.set("mykey", 10)) == :ok
    assert (c[:c] |> R.incrby("mykey", 5)) == 15
    assert (c[:c] |> R.get("mykey")) == "15"
  end

  test "incrbyfloat", c do
    assert (c[:c] |> R.set("mykey", "10.50")) == :ok
    assert (c[:c] |> R.incrbyfloat("mykey", "0.1")) == "10.6"
    assert (c[:c] |> R.get("mykey")) == "10.6"
  end

  test "info", c do
    assert is_nil(c[:c] |> R.info("stats")) == false
  end

  test "set", c do
    assert (c[:c] |> R.set("key-2", "value-2")) == :ok
    assert (c[:c] |> R.get("key-2")) == "value-2"
  end

  test "setbit", c do
    assert (c[:c] |> R.setbit("bitkey", 7, 1)) == 0
    assert (c[:c] |> R.setbit("bitkey", 7, 0)) == 1
    assert (c[:c] |> R.get("bitkey")) == <<0>>
  end

  test "setex", c do
    assert (c[:c] |> R.setex("mykey", 10, "Hello")) == :ok
    assert (c[:c] |> R.ttl("mykey")) == 10
    assert (c[:c] |> R.get("mykey")) == "Hello"
  end

  test "setnx", c do
    assert (c[:c] |> R.setnx("mykey", "Hello")) == 1
    assert (c[:c] |> R.setnx("mykey", "World")) == 0
    assert (c[:c] |> R.get("mykey")) == "Hello"
  end

  test "setrange", c do
    assert (c[:c] |> R.set("mykey", "Hello World")) == :ok
    assert (c[:c] |> R.setrange("mykey", 6, "Redis")) == 11
    assert (c[:c] |> R.get("mykey")) == "Hello Redis"
  end

  test "strlen", c do
    assert (c[:c] |> R.set("mykey", "Hello World")) == :ok
    assert (c[:c] |> R.strlen("mykey")) == 11
    assert (c[:c] |> R.strlen("nonexisting")) == 0
  end

  test "mset", c do
    assert (c[:c] |> R.mset(["k1", "v1", "k2", "v2"])) == :ok
    assert (c[:c] |> R.get("k1")) == "v1"
    assert (c[:c] |> R.get("k2")) == "v2"
  end

  test "mget", c do
    assert (c[:c] |> R.mset(["k1", "v1", "k2", "v2"])) == :ok
    assert (c[:c] |> R.mget(["k1", "k2"])) == ["v1", "v2"]
  end

  ##
  # Hashes
  ##

  test "hdel", c do
    assert (c[:c] |> R.hset("myhash", "field1", "foo")) == 1
    assert (c[:c] |> R.hdel("myhash", "field1")) == 1
    assert (c[:c] |> R.hdel("myhash", "field2")) == 0
  end

  test "hexists", c do
    assert (c[:c] |> R.hset("myhash", "field1", "foo")) == 1
    assert (c[:c] |> R.hexists("myhash", "field1")) == 1
    assert (c[:c] |> R.hexists("myhash", "field2")) == 0
  end

  test "hgetall", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hset("myhash", "field2", "World")) == 1
    assert (c[:c] |> R.hgetall("myhash")) == %{"field1" => "Hello", "field2" => "World"}
  end

  test "hincrby", c do
    assert (c[:c] |> R.hset("myhash", "field", 5)) == 1
    assert (c[:c] |> R.hincrby("myhash", "field", 1)) == 6
    assert (c[:c] |> R.hincrby("myhash", "field", -1)) == 5
    assert (c[:c] |> R.hincrby("myhash", "field", -10)) == -5
  end

  test "hincrbyfloat", c do
    assert (c[:c] |> R.hset("myhash", "field", "10.50")) == 1
    assert (c[:c] |> R.hincrbyfloat("myhash", "field", "0.1")) == "10.6"
    assert (c[:c] |> R.hset("myhash", "field", "5.0e3")) == 0
    assert (c[:c] |> R.hincrbyfloat("myhash", "field", "2.0e2")) == "5200"
  end

  test "hkeys", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hset("myhash", "field2", "World")) == 1
    assert (c[:c] |> R.hkeys("myhash")) == ["field1", "field2"]
  end

  test "hlen", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hset("myhash", "field2", "World")) == 1
    assert (c[:c] |> R.hlen("myhash")) == 2
  end

  test "hmget", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hset("myhash", "field2", "World")) == 1
    assert (c[:c] |> R.hmget("myhash", ["field1", "field2", "nofield"])) == ["Hello", "World", :undefined]
  end

  test "hmset", c do
    assert (c[:c] |> R.hmset("myhash", ["field1", "Hello", "field2", "World"])) == :ok
    assert (c[:c] |> R.hget("myhash", "field1")) == "Hello"
    assert (c[:c] |> R.hget("myhash", "field2")) == "World"
  end

  test "hget", c do
    assert (c[:c] |> R.hset("myhash", "field1", "foo")) == 1
    assert (c[:c] |> R.hget("myhash", "field1")) == "foo"
    assert (c[:c] |> R.hget("myhash", "field2")) == :undefined
  end

  test "hset", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hget("myhash", "field1")) == "Hello"
  end

  test "hsetnx", c do
    assert (c[:c] |> R.hsetnx("myhash", "field", "Hello")) == 1
    assert (c[:c] |> R.hsetnx("myhash", "field", "World")) == 0
    assert (c[:c] |> R.hget("myhash", "field")) == "Hello"
  end

  test "hvals", c do
    assert (c[:c] |> R.hset("myhash", "field1", "Hello")) == 1
    assert (c[:c] |> R.hset("myhash", "field2", "World")) == 1
    assert (c[:c] |> R.hvals("myhash")) == ["Hello", "World"]
  end

  ##
  # Multi
  ##

  test "multi", c do
    assert (c[:c] |> R.multi) == "OK"
    assert (c[:c] |> R.set("incrm", 0)) == "QUEUED"
    assert (c[:c] |> R.incr("incrm")) == "QUEUED"
    assert (c[:c] |> R.exec) == ["OK", "1"]
  end

  ##
  # Pub/Sub
  ##

  test "publish", c do
    assert (c[:c] |> R.publish("ch", "msg")) == 0
  end

  ##
  # Server
  ##

  test "flushall", c do
    assert (c[:c] |> R.flushall) == :ok
    assert (c[:c] |> R.get("key")) == :undefined
  end

  describe "defaultclient/0" do
    test "concurrently registering :exredis_hapi_default_client does not fail" do
      with [pid] <- [Task.async(&R.defaultclient/0),
                     Task.async(&R.defaultclient/0),
                     Task.async(&R.defaultclient/0),
                     Task.async(&R.defaultclient/0),
                     Task.async(&R.defaultclient/0)] |> Enum.map(&Task.await/1)
                                                     |> Enum.uniq do
        assert is_pid(pid)
      end
    end
  end
end
