Code.require_file "test_helper.exs", __DIR__

defmodule PubsubTest do
  use ExUnit.Case
  alias Exredis, as: E
  alias Exredis.Sub, as: S
  alias Exredis.Api, as: R

  test "connect" do
    assert S.start_link |> elem(1) |> is_pid
  end

  test "connect, erlang way" do
    {:ok, pid} = S.start_link

    assert pid |> is_pid
  end

  test "connect using connection string" do
    assert S.start_using_connection_string("redis://127.0.0.1:6379") |> is_pid
  end

  test "disconnect" do
    assert (S.start_link |> elem(1) |> S.stop) == :ok
  end

  test "pub/sub" do
    {:ok, client_sub} = S.start_link
    {:ok, client} = E.start_link
    pid = Kernel.self

    client_sub |> S.subscribe("foo", fn(msg) ->
      send(pid, msg)
    end)

    receive do
      msg ->
        assert (msg |> elem(0)) == :subscribed
        assert (msg |> elem(1)) == "foo"

    end

    client |> R.publish("foo", "Hello World!")

    receive do
      msg ->
        assert (msg |> elem(0)) == :message
        assert (msg |> elem(1)) == "foo"
        assert (msg |> elem(2)) == "Hello World!"

    end
  end


  test "pub/sub with multiple channels" do
    {:ok, client_sub} = S.start_link
    {:ok, client} = E.start_link
    pid = Kernel.self

    client_sub |> S.subscribe(["foo", "bar"], fn(msg) ->
      send(pid, msg)
    end)

    receive do
      msg ->
        assert (msg |> elem(0)) == :subscribed
        assert (msg |> elem(1)) == "foo"
    end

    receive do
      msg ->
        assert (msg |> elem(0)) == :subscribed
        assert (msg |> elem(1)) == "bar"
    end

    client |> R.publish("foo", "Hello World!")

    receive do
      msg ->
        assert (msg |> elem(0)) == :message
        assert (msg |> elem(1)) == "foo"
        assert (msg |> elem(2)) == "Hello World!"

    end
  end


  test "pub/sub by a pattern" do
    {:ok, client_sub} = S.start_link
    {:ok, client} = E.start_link
    pid = Kernel.self

    client_sub |> S.psubscribe("bar_*", fn(msg) ->
      send(pid, msg)
    end)

    receive do
      msg ->
        assert (msg |> elem(0)) == :subscribed
        assert (msg |> elem(1)) == "bar_*"

    end

    client |> R.publish("bar_test", "Hello World!")

    receive do
      msg ->
        assert (msg |> elem(0)) == :pmessage
        assert (msg |> elem(1)) == "bar_*"
        assert (msg |> elem(2)) == "bar_test"
        assert (msg |> elem(3)) == "Hello World!"

    end
  end
end
