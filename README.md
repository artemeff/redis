### Redis [![Build Status](https://img.shields.io/travis/artemeff/redis.svg)](https://travis-ci.org/artemeff/redis) [![Hex.pm](https://img.shields.io/hexpm/v/redis.svg)](https://hex.pm/packages/redis)

---

[Redis](http://redis.io) commands for Elixir. If you are looking for exredis, please check out [exredis](https://github.com/artemeff/exredis/tree/exredis) branch.

---

* [Installation](#installation)
* [Usage](#usage)
* [API reference](http://hexdocs.pm/redis/)
* [Contributing](#contributing)

---

### Installation

Add this to the dependencies:

```elixir
{:redis, "~> 0.1"}
```

---

### Usage

Redis commands have a few simple types: enums, commands and primitive. Types can be required and optional, multiple and variadic, can be composite.

Situation with required and optional types is simple: required types are just arguments in function and optional values passed with the last argument — `opts`. opts is just a list, opts described in typespecs for each command.

Multiple arguments are arguments that contain one or more values. Multiple arguments can be optional.

Enum types in Redis is just a enumerable (usually), take a look at `xx | nx` enum:

```elixir
iex> Redis.set("key", "value", [:xx])
["SET", [" ", "key"], [" ", "value"], [], [" ", "XX"]]

iex> Redis.set("key", "value", [:nx])
["SET", [" ", "key"], [" ", "value"], [], [" ", "NX"]]
```

Commands are prefixed types, commands can wrap primitive types, enums and composite types:

```elixir
# command with enum inside
iex> Redis.client_kill(type: :master)
["CLIENT KILL", [], [], [" ", ["TYPE", " ", "master"]], [], []]

# command with primitive type inside
iex> Redis.client_kill(id: "identity")
["CLIENT KILL", [], [" ", ["ID", " ", "identity"]], [], [], []]

# command with composite type inside, inner type of get is: {String.t, integer()}
iex> Redis.bitfield("key", get: {"type", "offset"})
["BITFIELD", [" ", "key"], [" ", ["GET", " ", ["type", " ", "offset"]]], [], [], []]
```

You can see the usage for every Redis command in IEx:

```elixir
iex> h Redis.set

  def set(key, value, opts \\ [])

  @spec set(
          key :: key(),
          value :: String.t(),
          opts :: [
            {:expiration, {:ex, :integer} | {:px, :integer}}
            | (:nx | :xx)
            | {:condition, :nx | :xx}
          ]
        ) :: iolist()

since: 1.0.0

Set the string value of a key

Group: string.
```

Or head to the [documentation on hexdocs](http://hexdocs.pm/redis/).

---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
