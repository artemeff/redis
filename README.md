## exredis [![Build Status](https://travis-ci.org/artemeff/exredis.png?branch=master)](https://travis-ci.org/artemeff/exredis)

Redis client for Elixir

---

### Installation

Add this to the dependencies:

```elixir
{ :exredis, "0.0.2", [ github: "artemeff/exredis", tag: "v0.0.2" ] }
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
use Exredis.Sub

client_sub = start
client = Exredis.start
pid = Kernel.self

client_sub |> subscribe "foo", fn(msg) ->
  pid <- msg
end

receive do
  msg ->
    IO.inspect msg
    # => { :subscribed, "foo", #PID<0.85.0> }
end

client |> publish "foo", "Hello World!"

receive do
  msg ->
    IO.inspect msg
    # => { :message, "foo", "Hello World!", #PID<0.85.0> }
end
```

__Pub/sub by a pattern__

```elixir
client_sub = start
client = Exredis.start
pid = Kernel.self

client_sub |> psubscribe "bar_*", fn(msg) ->
  pid <- msg
end

receive do
  msg ->
    IO.inspect msg
    # => { :subscribed, "bar_*", #PID<0.104.0> }
end

client |> publish "bar_test", "Hello World!"

receive do
  msg ->
    IO.inspect msg
    # => { :pmessage, "bar_*", "bar_test", "Hello World!", #PID<0.104.0> }
end
```

---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
