defmodule Exredis.Api.Helper do
  defmacro __using__(_) do
    quote do
      import Exredis, only: [query: 2]
      import Exredis.Api.Helper
    end
  end

  defmacro defredis(cmd, args, fun \\ nil) do
    margs = Enum.map args, fn(x) -> {x, [], ExRedis.Api.Helper} end
    cmd = if is_list(cmd), do: cmd, else: [cmd]
    cmd_name = Enum.map(cmd, fn(x) -> atom_to_list(x) end)
      |> Enum.join("_") |> binary_to_atom
    method = Enum.map cmd, fn(x) -> atom_to_binary(x) |> String.upcase end
    quote do
      def unquote(cmd_name)(client, unquote_splicing(margs)) do
        f = unquote(fun)
        query_args = List.flatten [unquote_splicing(method)|[unquote_splicing(margs)]]
        res = Exredis.query client, query_args
        if f, do: f.(res), else: res
      end

      def unquote(cmd_name)(unquote_splicing(margs)) do
        unquote(cmd_name)(defaultclient, unquote_splicing(margs))
      end
    end
  end
end

defmodule Exredis.Api do
  @moduledoc """
  High-level API
  """

  use Exredis.Api.Helper

  defmacro __using__(_opts) do
    quote do
      import Exredis.Api
    end
  end

  defp defaultclient do
    pid = Process.whereis(:exredis_hapi_default_client)
    if !pid do
      pid = Exredis.start
      Process.register pid, :exredis_hapi_default_client
    end
    pid
  end

  defredis :append, [:key, :value], &int_reply/1
  defredis :auth, [:password]
  defredis :bgrewriteaof, []
  defredis :bgsave, []
  defredis :bitcount, [:key, :start, :end], &int_reply/1
  defredis :bitcount, [:key], &int_reply/1
  defredis :bitop, [:operation, :destkey, :key]#, ...]
  defredis :blpop, [:key, :timeout]
  defredis :brpop, [:key, :timeout]
  defredis :brpoplpush, [:source, :destination, :timeout]
  defredis :dbsize, []
  defredis :decr, [:key], &int_reply/1
  defredis :decrby, [:key, :decrement], &int_reply/1
  defredis :del, [:key], &int_reply/1
  defredis :discard, []
  defredis :dump, [:key]
  defredis :echo, [:message]
  defredis :eval, [:script, :numkeys, :keys, :args]
  defredis :evalsha, [:scriptsha, :numkeys, :keys, :args]
  defredis :exec, []
  defredis :exists, [:key], &int_reply/1
  defredis :expire, [:key, :seconds], &int_reply/1
  defredis :expireat, [:key, :timestamp], &int_reply/1
  defredis :flushall, [], &sts_reply/1
  defredis :flushdb, []
  defredis :get, [:key]
  defredis :getbit, [:key, :offset], &int_reply/1
  defredis :getrange, [:key, :start, :end]
  defredis :getset, [:key, :value]
  defredis :hdel, [:key, :field], &int_reply/1#, ...]
  defredis :hexists, [:key, :field], &int_reply/1
  defredis :hget, [:key, :field]
  defredis :hgetall, [:key], fn x ->
    Enum.chunk(x, 2) 
      |> Enum.map(fn [a, b] -> {a, b} end) 
      |> Enum.into(Map.new)
  end
  defredis :hincrby, [:key, :field, :increment], &int_reply/1
  defredis :hincrbyfloat, [:key, :field, :increment]
  defredis :hkeys, [:key]
  defredis :hlen, [:key], &int_reply/1
  defredis :hmget, [:key, :field]#, ...]
  defredis :hmset, [:key, :vals], &sts_reply/1
  defredis :hset, [:key, :field, :value], &int_reply/1
  defredis :hsetnx, [:key, :field, :value], &int_reply/1
  defredis :hvals, [:key]
  defredis :incr, [:key], &int_reply/1
  defredis :incrby, [:key, :increment], &int_reply/1
  defredis :incrbyfloat, [:key, :increment]
  # defredis :info, []
  defredis :keys, [:pattern]
  defredis :lastsave, []
  defredis :lindex, [:key, :index]
  defredis :linsert, [:key, :before_after, :pivot, :value]
  defredis :llen, [:key]
  defredis :lpop, [:key]
  defredis :lpush, [:key, :value]#, ...]
  defredis :lpushx, [:key, :value]
  defredis :lrange, [:key, :start, :stop]
  defredis :lrem, [:key, :count, :value]
  defredis :lset, [:key, :index, :value]
  defredis :ltrim, [:key, :start, :stop]
  defredis :mget, [:key], &sts_reply/1#, ...]
  # defredis :migrate
  defredis :monitor, []
  defredis :move, [:key, :db]
  defredis :mset, [:vals], &sts_reply/1#, ...]
  defredis :msetnx, [:key, :value]#, ...]
  defredis :multi, []
  # defredis :object, []
  defredis :persist, [:key], &int_reply/1
  defredis :pexpire, [:key, :milliseconds], &int_reply/1
  defredis :pexpireat, [:key, :milli_timestamp], &int_reply/1
  defredis :ping, []
  defredis :psetex, [:key, :milliseconds, :value]
  defredis :psubscribe, [:pattern]#, ...]
  # defredis :pubsub, [:subcommand]
  defredis :pttl, [:key], &int_reply/1
  defredis :publish, [:channel, :message], &int_reply/1
  defredis :punsubscribe, [:pattern]#, ...]
  defredis :quit, []
  defredis :randomkey, []
  defredis :rename, [:key, :newkey], &sts_reply/1
  defredis :renamenx, [:key, :newkey], &int_reply/1
  defredis :restore, [:key, :ttl, :serialized_value]
  defredis :rpop, [:key]
  defredis :rpoplpush, [:source, :destination]
  defredis :rpush, [:key, :value]#, ...]
  defredis :rpushx, [:key, :value]#, ...]
  defredis :sadd, [:key, :member]#, ...]
  defredis :save, []
  defredis :scard, [:key]
  defredis [:script, :exists], [:shasum], &multi_int_reply/1
  defredis [:script, :flush], [], &sts_reply/1
  defredis [:script, :kill], []
  defredis [:script, :load], [:script]
  defredis :sdiff, [:key]#, ...]
  defredis :sdiffstore, [:destination, :key]#, ...]
  defredis :select, [:index]
  defredis :set, [:key, :value], &sts_reply/1
  defredis :setbit, [:key, :offset, :value], &int_reply/1
  defredis :setex, [:key, :seconds, :value], &sts_reply/1
  defredis :setnx, [:key, :value], &int_reply/1
  defredis :setrange, [:key, :offset, :value], &int_reply/1
  # defredis :shutdown, [:nosave, :save]
  defredis :sinter, [:key]#, ...]
  defredis :sinterstore, [:destination, :key]#, ...]
  defredis :sismember, [:key, :member]
  defredis :slaveof, [:host, :port]
  defredis :slowlog, [:subcommand]#, :argument]
  defredis :smembers, [:key]
  defredis :smove, [:source, :destination, :member]
  defredis :sort, [:key]#, :by_pattern]
  defredis :spop, [:key]
  defredis :srandmember, [:key]#, :count]
  defredis :srem, [:key, :member]#, ...]
  defredis :strlen, [:key], &int_reply/1
  defredis :subscribe, [:channel]#, ...]
  defredis :sunion, [:key]#, ...]
  defredis :sunionstore, [:destination, :key]#, ...]
  defredis :sync, []
  defredis :time, []
  defredis :ttl, [:key], &int_reply/1
  defredis :type, [:key]
  defredis :unsubscribe, [:channel]#, ...]
  defredis :unwatch, []
  defredis :watch, [:key]#, ...]
  defredis :zadd, [:key, :score, :member]#, ...]
  defredis :zcard, [:key]
  defredis :zcount, [:key, :min, :max]
  defredis :zincrby, [:key, :increment, :member]
  defredis :zinterstore, [:destination, :numkeys, :key]#, ...]
  defredis :zrange, [:key, :start, :stop]
  defredis :zrangebyscore, [:key, :start, :stop]
  defredis :zrank, [:key, :member]
  defredis :zrem, [:key, :member]#, ...]
  defredis :zremrangebyrank, [:key, :start, :stop]
  defredis :zremrangebyscore, [:key, :min, :max]
  defredis :zrevrange, [:key, :start, :stop]
  defredis :zrevrangebyscore, [:key, :min, :max]
  defredis :zrevrank, [:key, :member]
  defredis :zscore, [:key, :member]
  defredis :zunionstore, [:destination, :key]#, ...]
  # defredis :scan, [:cursor]
  # defredis :sscan, [:key, :cursor]
  # defredis :hscan, [:key, :cursor]
  # defredis :zscan, [:key, :cursor]

  defp int_reply(reply), do:
    reply |> binary_to_integer

  defp multi_int_reply(reply), do:
    reply |> Enum.map &int_reply/1

  defp sts_reply("OK"), do:
    :ok

  defp sts_reply(reply), do:
    reply

end
