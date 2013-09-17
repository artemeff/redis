Code.require_file "test_helper.exs", __DIR__

defmodule ApiMixin do
  use Exredis.Api

  def set(client), do:
    client |> set "key", "value"

  def get(client), do:
    client |> get "key"

end

defmodule ApiTest do
  use ExUnit.Case, sync: true
  alias Exredis, as: E
  alias Exredis.Api, as: R

  setup do
    client = E.start

    # clean up database and set test value
    client |> E.query ["FLUSHALL"]
    client |> E.query ["SET", "key", "value"]

    { :ok, [c: client] }
  end

  teardown ctx, do:
    ctx[:c] |> E.stop


  test "mixin", c do
    assert (c[:c] |> ApiMixin.set) == :ok
    assert (c[:c] |> ApiMixin.get) == "value"
  end

  ##
  # Keys
  ##

  test "del", c do
    assert (c[:c] |> R.del "key") == 1
    assert (c[:c] |> R.del ["key1", "key2"]) == 0
  end

  test "keys", c do
    c[:c] |> R.flushall
    c[:c] |> R.mset ["k1", "v1", "k2", "v2"]

    assert length(c[:c] |> R.keys "k*") == 2
  end

  test "pexpire", c do
    assert (c[:c] |> R.pexpire "key", "1500") == 1
    assert (c[:c] |> R.pexpire "non-existing-key", "1500") == 0
  end

  test "renamenx", c do
    assert (c[:c] |> R.renamenx "key", "new_key") == 1
  end

  test "dump", c do
    assert is_binary(c[:c] |> R.dump "key") == true
  end

  test "migrate", _c do
    # TODO
  end

  test "pexpireat", c do
    assert (c[:c] |> R.pexpireat "key", "1500") == 1
    assert (c[:c] |> R.pexpireat "non-existing-key", "1500") == 0
  end

  test "restore", _c do
    # TODO
  end

  test "exists", c do
    assert (c[:c] |> R.exists "key") == 1
    assert (c[:c] |> R.exists "non-existing-key") == 0
  end

  test "move", _c do
    # TODO
  end

  test "pttl", c do
    assert (c[:c] |> R.pttl "key") == -1
  end

  test "sort", _c do
    # TODO
  end

  test "expire", c do
    assert (c[:c] |> R.expire "key", "1500") == 1
    assert (c[:c] |> R.expire "non-existing-key", "1500") == 0
  end

  test "object", _c do
    # TODO
  end

  test "randomkey", c do
    assert (c[:c] |> R.randomkey) == "key"
  end

  test "ttl", c do
    assert (c[:c] |> R.ttl "key") == -1
  end

  test "expireat", c do
    assert (c[:c] |> R.expireat "key", "1293840000") == 1
  end

  test "persist", c do
    assert (c[:c] |> R.persist "key") == 0
  end

  test "rename", c do
    assert (c[:c] |> R.rename "key", "new_key") == :ok
  end

  test "type", c do
    assert (c[:c] |> R.type "key") == "string"
  end

  ##
  # Strigns
  ##

  test "append", c do
    assert (c[:c] |> R.append "mykey", "hello") == 5
    assert (c[:c] |> R.append "mykey", " world") == 11
    assert (c[:c] |> R.get "mykey") == "hello world"
  end

  test "bitcount", c do
    assert (c[:c] |> R.set "mykey", "foobar") == :ok
    assert (c[:c] |> R.bitcount "mykey") == 26
    assert (c[:c] |> R.bitcount "mykey", 0, 0) == 4
    assert (c[:c] |> R.bitcount "mykey", 1, 1) == 6
  end

  test "decr", c do
    assert (c[:c] |> R.set "mykey", 10) == :ok
    assert (c[:c] |> R.decr "mykey") == 9
  end

  test "decrby", c do
    assert (c[:c] |> R.set "mykey", 10) == :ok
    assert (c[:c] |> R.decrby "mykey", 5) == 5
  end

  test "get", c do
    assert (c[:c] |> R.get "key") == "value"
  end

  test "set", c do
    assert (c[:c] |> R.set "key-2", "value-2") == :ok
    assert (c[:c] |> R.get "key-2") == "value-2"
  end

  test "mset", c do
    assert (c[:c] |> R.mset ["k1", "v1", "k2", "v2"]) == :ok
    assert (c[:c] |> R.get "k1") == "v1"
    assert (c[:c] |> R.get "k2") == "v2"
  end

  test "mget", c do
    assert (c[:c] |> R.mset ["k1", "v1", "k2", "v2"]) == :ok
    assert (c[:c] |> R.mget ["k1", "k2"]) == ["v1", "v2"]
  end

  ##
  # Pub/Sub
  ##

  test "publish", c do
    assert (c[:c] |> R.publish "ch", "msg") == 0
  end

  ##
  # Server
  ##

  test "flushall", c do
    assert (c[:c] |> R.flushall) == :ok
    assert (c[:c] |> R.get "key") == :undefined
  end

end
