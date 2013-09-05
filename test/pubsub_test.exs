Code.require_file "test_helper.exs", __DIR__

defmodule PubsubTest do
  use ExUnit.Case
  alias Exredis, as: E
  alias Exredis.Sub, as: S

  test "pub/sub" do
    client_sub = S.start
    client = E.start
    pid = Kernel.self
    
    client_sub |> S.subscribe "foo", fn(msg) ->
      pid <- msg
    end

    receive do
      msg ->
        assert (msg |> elem 0) == :subscribed
        assert (msg |> elem 1) == "foo"

    end

    client |> E.publish "foo", "Hello World!"

    receive do
      msg ->
        assert (msg |> elem 0) == :message
        assert (msg |> elem 1) == "foo"
        assert (msg |> elem 2) == "Hello World!"
        
    end
  end

  test "pub/sub by a pattern" do
    client_sub = S.start
    client = E.start
    pid = Kernel.self
    
    client_sub |> S.psubscribe "bar_*", fn(msg) ->
      pid <- msg
    end

    receive do
      msg ->
        assert (msg |> elem 0) == :subscribed
        assert (msg |> elem 1) == "bar_*"

    end

    client |> E.publish "bar_test", "Hello World!"

    receive do
      msg ->
        assert (msg |> elem 0) == :pmessage
        assert (msg |> elem 1) == "bar_*"
        assert (msg |> elem 2) == "bar_test"
        assert (msg |> elem 3) == "Hello World!"

    end
  end
end
