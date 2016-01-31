Code.require_file "test_helper.exs", __DIR__

defmodule ConfigTest do
  use ExUnit.Case, async: false

  @redis_url "redis://user:password@host:1234/10"

  setup do
    on_exit fn ->
      System.delete_env("foobar")
      System.delete_env("port")
      (Exredis.Config.settings ++ [:url])
        |> Enum.each(fn key -> Application.put_env(:exredis, key, nil) end)
    end

  end

  test "prefer application value" do
    Application.put_env(:exredis, :url, @redis_url)
    Application.put_env(:exredis, :host, :host_exmaple)
    config = Exredis.Config.fetch_env
    assert config.host == :host_exmaple
  end

  test "knows how to understand :system tuple" do
    System.put_env("foobar", "baz")
    System.put_env("port", "4185")
    Application.put_env(:exredis, :host, {:system, "foobar"})
    Application.put_env(:exredis, :port, {:system, "port"})
    config = Exredis.Config.fetch_env

    assert config.host == "baz"
    assert 4185 == config.port
  end
  test "can always turn string into integer for port" do
    Application.put_env(:exredis, :port, "6378")
    config = Exredis.Config.fetch_env
    assert 6378 == config.port
  end
  test "can always leave integer alone for port" do
    Application.put_env(:exredis, :port, 6378)
    config = Exredis.Config.fetch_env

    assert 6378 == config.port
  end

  test "prefare uri value then default" do
    Application.put_env(:exredis, :url, @redis_url)
    config = Exredis.Config.fetch_env
    assert config.host == "host"
  end


  test "use default there is no any variants" do
    config = Exredis.Config.fetch_env
    assert config.host == "127.0.0.1"
  end
end
