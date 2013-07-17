## exredis [![Build Status](https://travis-ci.org/artemeff/exredis.png?branch=master)](https://travis-ci.org/artemeff/exredis)

Redis client for Elixir

---

### Installation

Add this to the dependencies:

```elixir
# edge
{ :exredis, "0.0.2", [ github: "artemeff/exredis" ] }

# stable
{ :exredis, "0.0.1", [ github: "artemeff/exredis", tag: "0.0.1" ] }
```

---

### Usage

__As mixin__

```elixir
defmodule Pi do
  use Exredis

  def get, do: start |> query ["GET", "Pi"]
  def set, do: start |> query ["SET", "Pi", "3.14"]
end

Pi.set
# => "OK"

Pi.get
# => "3.14"
```

__Connect to the Redis server__

```elixir
client = Exredis.start
```

__Disconnect from the server__

```elixir
Exredis.stop client
```

__Set & Get__

```elixir
# set
Exredis.query(client, ["SET", "FOO", "BAR"])

# get
Exredis.query(client, ["GET", "FOO"])
# => "BAR"
```

__Mset & Mget__

```elixir
# mset
Exredis.query(client, ["MSET" | ["key1", "value1", "key2", "value2", "key3", "value3"]])

# mget
Exredis.query(client, ["MGET" | ["key1", "key2", "key3"]])
# => ["value1","value2","value3"]
```

__Transactions__

```elixir
# start
Exredis.query(client, ["MULTI"])

# exec
Exredis.query(client, ["SET", "foo", "bar"])
Exredis.query(client, ["SET", "bar", "baz"])

# commit
Exredis.query(client, ["EXEC"])
```

__Pipelining__

```elixir
Exredis.query_pipe(client, [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]])
```

__Pub/sub__

```elixir
# subscribe, early documentation
# api should be improve, for now it's ugly

# define callback
def sub_callback(client, main_pid) do
  receive do
    msg ->
      case msg do
        {:subscribed, _channel, _pid} ->
          main_pid <- "connect"

        {:message, _channel, msg, _pid} ->
          main_pid <- "message #{msg}"

        _other -> nil
      end

      Exredis.Sub.ack_message client
      sub_callback client, main_pid
  end
end

# sub_callback as anonymous function
callback = function(sub_callback/2)

# start client for subscribe
client_sub = Exredis.Sub.start

# subscribe!
Exredis.Sub.subscribe(client_sub, "foo", callback, Kernel.self)

# receive messages
receive do
  msg -> IO.inspect msg
end

# publish
Exredis.Sub.publish(client, "foo", "bar")
```

---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
