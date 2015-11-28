### exredis [![Build Status](https://img.shields.io/travis/artemeff/exredis.svg)](https://travis-ci.org/artemeff/exredis) [![Hex.pm](https://img.shields.io/hexpm/v/exredis.svg)](https://hex.pm/packages/exredis)

---

[Redis](http://redis.io) client for Elixir.

---

### Installation

Add this to the dependencies:

```elixir
{:exredis, ">= 0.2.2"}
```

---

### Configuration

In your applications config.exs file you need to add new section for customizing redis connection.

```elixir
config :exredis,
  host: "127.0.0.1",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  max_queue: :infinity
```

or

```elixir
config :exredis,
  url: "redis://user:password@host:1234/10",
  reconnect: :no_reconnect,
  max_queue: :infinity
```

### Usage ([web docs](http://hexdocs.pm/exredis/))

__As mixin__

```elixir
defmodule Pi do
  import Exredis

  def get, do: start_link |> elem(1) |> query ["GET", "Pi"]
  def set, do: start_link |> elem(1) |> query ["SET", "Pi", "3.14"]
end

Pi.set
# => "OK"

Pi.get
# => "3.14"
```

```elixir
defmodule Api do
  import Exredis.Api

  def set(client), do:
    client |> set "key", "value"

  def get(client), do:
    client |> get "key"

end

{:ok, client} = Exredis.start_link

client |> Api.set
# => "OK"

client |> Api.get
# => "value"
```

__Connect to the Redis server__

```elixir
{:ok, client} = Exredis.start_link
# or
client = Exredis.start_using_connection_string("redis://127.0.0.1:6379")
```

__Disconnect from the server__

```elixir
client |> Exredis.stop
```

__Set & Get__

```elixir
# set
client |> Exredis.query ["SET", "FOO", "BAR"]

# get
client |> Exredis.query ["GET", "FOO"]
# => "BAR"
```

__Mset & Mget__

```elixir
# mset
client |> Exredis.query ["MSET" | ["key1", "value1", "key2", "value2", "key3", "value3"]]

# mget
client |> Exredis.query ["MGET" | ["key1", "key2", "key3"]]
# => ["value1", "value2", "value3"]
```

__Transactions__

```elixir
# start
client |> Exredis.query ["MULTI"]

# exec
client |> Exredis.query ["SET", "foo", "bar"]
client |> Exredis.query ["SET", "bar", "baz"]

# commit
client |> Exredis.query ["EXEC"]
```

__Pipelining__

```elixir
client |> Exredis.query_pipe [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]]
```

__Pub/sub__

```elixir
{:ok, client_sub} = Exredis.Sub.start_link
{:ok, client} = Exredis.start_link
pid = Kernel.self

client_sub |> Exredis.Sub.subscribe "foo", fn(msg) ->
  send(pid, msg)
end

receive do
  msg ->
    IO.inspect msg
    # => {:subscribed, "foo", #PID<0.85.0>}
end

client |> Exredis.Api.publish "foo", "Hello World!"

receive do
  msg ->
    IO.inspect msg
    # => {:message, "foo", "Hello World!", #PID<0.85.0>}
end
```

__Pub/sub by a pattern__

```elixir
{:ok, client_sub} = Exredis.Sub.start_link
{:ok, client} = Exredis.start_link
pid = Kernel.self

client_sub |> Exredis.Sub.psubscribe "bar_*", fn(msg) ->
  send(pid, msg)
end

receive do
  msg ->
    IO.inspect msg
    # => {:subscribed, "bar_*", #PID<0.104.0>}
end

client |> Exredis.Api.publish "bar_test", "Hello World!"

receive do
  msg ->
    IO.inspect msg
    # => {:pmessage, "bar_*", "bar_test", "Hello World!", #PID<0.104.0>}
end
```

__Scripting__

```elixir
client |> Exredis.Api.script_load "return 1 + 1"
# => "c301e0c5bc3538d2bad3fdbf2e281887e643ada4"
client |> Exredis.Api.evalsha "c301e0c5bc3538d2bad3fdbf2e281887e643ada4", 0, ["key1"], ["argv1"]
# => "2"

defmodule MyScripts do
  import Exredis.Script

  defredis_script :lua_echo, "return ARGV[1]"
  defredis_script :huge_command, file_path: "lua_scripts/huge_command.lua"
end

client |> MyScripts.lua_echo(["mykey"], ["foo"])
# => "foo"
```
---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
