defmodule LuaScriptMixin do
  use Exredis.Script

  defredis_script :return_one, "return 1"
  defredis_script :return_keys, "return KEYS"
  defredis_script :return_keys_and_argv, "return {KEYS, ARGV}"
end

defmodule ScriptTest do
  use ExUnit.Case, sync: true
  alias Exredis, as: E
  alias Exredis.Api, as: R

  @lua_script "return {KEYS,ARGV}"
  @lua_script_sha "667538fc7bc1737be485fe688c8f39e7ddc79782"
  @lua_script_sha_non_existing "9c609a7ccf8e2ef9459f7f88c414c951e3d174d9"

  setup do
    client = E.start

    # clean up database and set test value
    client |> E.query ["FLUSHALL"]
    client |> E.query ["SET", "key1", "value1"]
    client |> E.query ["SET", "key2", "value2"]

    { :ok, [c: client] }
  end

  teardown ctx, do:
    ctx[:c] |> E.stop

  test "script load", c do
    assert (c[:c] |> R.script_load(@lua_script)) == @lua_script_sha
  end

  test "script exists", c do
    assert (c[:c] |> R.script_load(@lua_script)) == @lua_script_sha
    assert (c[:c] |> R.script_exists(@lua_script_sha)) == [1]
    assert (c[:c] |> R.script_exists([@lua_script_sha, @lua_script_sha_non_existing])) == [1, 0]
  end

  test "script flush", c do
    assert (c[:c] |> R.script_load(@lua_script)) == @lua_script_sha
    assert (c[:c] |> R.script_flush) == :ok
    assert (c[:c] |> R.script_exists(@lua_script_sha)) == [0]
  end

  test "script kill", c do
    assert (c[:c] |> R.script_kill) == "NOTBUSY No scripts in execution right now."
  end

  test "eval", c do
    assert (c[:c] |> R.eval(@lua_script, 2, [:key1, :key2], [:argv1]))
      == [["key1", "key2"], ["argv1"]]
  end

  test "evalsha", c do
    assert (c[:c] |> R.script_flush) == :ok
    assert (c[:c] |> R.script_load(@lua_script)) == @lua_script_sha
    assert (c[:c] |> R.evalsha(@lua_script_sha, 2, [:key1, :key2], [:argv1]))
      == [["key1", "key2"], ["argv1"]]
  end

  test "defredis_script no arguments", c do
    assert (c[:c] |> LuaScriptMixin.return_one) == "1"
  end

  test "defredis_script with keys", c do
    assert (c[:c] |> LuaScriptMixin.return_keys([:key1, :key2])) == ["key1", "key2"]
  end

  test "defredis_script with keys and argv", c do
    assert (c[:c] |> LuaScriptMixin.return_keys_and_argv([:key1, :key2], [:argv1]))
      == [["key1", "key2"], ["argv1"]]
  end

end
