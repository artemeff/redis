Code.require_file "test_helper.exs", __DIR__

defmodule PubsubTest do
  use ExUnit.Case, async: true

  test "pub/sub" do
    client_sub = Exredis.Sub.start
    client_pub = Exredis.start
    callback   = function(Pi, :sub_callback, 2)

    Exredis.Sub.subscribe(client_sub, "foo", callback, Kernel.self)
    
    receive do
      msg -> assert msg == "connect"
    end

    Exredis.Sub.publish(client_pub, "foo", "bar")

    receive do
      msg -> assert msg == "message bar"
    end
  end
end
