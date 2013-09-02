Code.require_file "test_helper.exs", __DIR__

defmodule PubsubTest do
  use ExUnit.Case

  test "pub/sub" do
    client_sub = Exredis.Sub.start
    client = Exredis.start
    pid = Kernel.self
    
    client_sub |> Exredis.Sub.subscribe "foo", fn(msg) ->
      pid <- msg
    end

    receive do
      msg ->
        assert (msg |> elem 0) == :subscribed
        assert (msg |> elem 1) == "foo"

    end

    client |> Exredis.Sub.publish "foo", "Hello World!"

    receive do
      msg ->
        assert (msg |> elem 0) == :message
        assert (msg |> elem 1) == "foo"
        assert (msg |> elem 2) == "Hello World!"
        
    end
  end

  test "pub/sub by a pattern" do
    client_sub = Exredis.Sub.start
    client = Exredis.start
    pid = Kernel.self
    
    client_sub |> Exredis.Sub.psubscribe "bar_*", fn(msg) ->
      pid <- msg
    end

    receive do
      msg ->
        assert (msg |> elem 0) == :subscribed
        assert (msg |> elem 1) == "bar_*"

    end

    client |> Exredis.Sub.publish "bar_test", "Hello World!"

    receive do
      msg ->
        assert (msg |> elem 0) == :pmessage
        assert (msg |> elem 1) == "bar_*"
        assert (msg |> elem 2) == "bar_test"
        assert (msg |> elem 3) == "Hello World!"

    end
  end
end
