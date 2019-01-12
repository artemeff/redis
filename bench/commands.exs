Benchee.run(%{
  "bitfield with all opts" => fn ->
    [
      "BITFIELD",
      [" ", "key"],
      [" ", ["GET", " ", ["type", " ", "offset"]]],
      [" ", ["SET", " ", ["type", " ", "offset", " ", "value"]]],
      [" ", ["INCRBY", " ", ["type", " ", "offset", " ", "increment"]]],
      [" ", ["OVERFLOW", " ", "WRAP"]]
    ] =
      Redis.bitfield("key", get: {"type", "offset"}, set: {"type", "offset", "value"},
                            incrby: {"type", "offset", "increment"}, overflow: :wrap)
  end,

  "georadius with opts as list" => fn ->
    [
      "GEORADIUSBYMEMBER",
      [" ", "key"],
      [" ", "member"],
      [" ", "radius"],
      [" ", "km"],
      [" ", "WITHCOORD"],
      [" ", "WITHDIST"],
      [],
      [" ", ["COUNT", " ", "1"]],
      [" ", "ASC"],
      [],
      []
    ] =
      Redis.georadiusbymember("key", "member", "radius", :km,
        [:asc, :withdist, :withcoord, count: "1"])
  end,

  "georadius with opts as keywords" => fn ->
    [
      "GEORADIUSBYMEMBER",
      [" ", "key"],
      [" ", "member"],
      [" ", "radius"],
      [" ", "km"],
      [" ", "WITHCOORD"],
      [" ", "WITHDIST"],
      [],
      [" ", ["COUNT", " ", "1"]],
      [" ", "ASC"],
      [],
      []
    ] =
      Redis.georadiusbymember("key", "member", "radius", :km,
        [order: :asc, withdist: :withdist, withcoord: :withcoord, count: "1"])
  end,

  "hmget" => fn ->
    ["HMGET", [" ", "key"], [" ", ["field1", " ", "field2"]]] =
      Redis.hmget("key", ["field1", "field2"])
  end,

  "hmset" => fn ->
    [
      "HMSET",
      [" ", "key"],
      [" ", [["field1", " ", "value1"], " ", ["field2", " ", "value2"]]]
    ] =
      Redis.hmset("key", [{"field1", "value1"}, {"field2", "value2"}])
  end,

  "set" => fn ->
    ["SET", [" ", "key"], [" ", "value"], [" ", ["PX", " ", "10000000"]], [" ", "XX"]] =
      Redis.set("key", "value", [:xx, expiration: {:px, 1_000_0000}])
  end,

}, time: 3, memory_time: 2, print: [fast_warning: false])
