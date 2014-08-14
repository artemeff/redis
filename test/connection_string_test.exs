Code.require_file "test_helper.exs", __DIR__

defmodule ConnectionStringTest do
  use ExUnit.Case, async: true

  test "parsing a connection string" do
    config = Exredis.ConnectionString.parse("redis://user:password@host:1234")
    assert config.host == 'host'
    assert config.port == 1234
    assert config.password == 'password'
  end

  test "parsing a connection string with db" do
    config = Exredis.ConnectionString.parse("redis://user:password@host:1234/10")
    assert config.host == 'host'
    assert config.port == 1234
    assert config.password == 'password'
    assert config.db == "10"
  end

  test "parsing a connection string without user" do
    config = Exredis.ConnectionString.parse("redis://:password@host:1234")
    assert config.host == 'host'
    assert config.port == 1234
    assert config.password == 'password'
  end

  test "parsing a connection string without password" do
    config = Exredis.ConnectionString.parse("redis://host:1234")
    assert config.host == 'host'
    assert config.port == 1234
    assert config.password == ''
  end
end
