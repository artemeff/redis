defmodule Exredis.Api.Helper do
  defmacro __using__(module) do
    quote do
      import Exredis.Api.Helper
    end
  end

  defmacro defredis(cmd, args, fun // nil) do
    margs = Enum.map args, fn(x) -> {x, [], ExRedis.Hapi} end
    quote do
      def unquote(cmd)(client, unquote_splicing(margs)) do
        method = String.upcase atom_to_binary unquote(cmd)
        f = unquote(fun)
        res = Exredis.query client, [method, unquote_splicing(margs)]
        if f, do: f.(res), else: res
      end

      def unquote(cmd)(unquote_splicing(margs)) do
        unquote(cmd)(defaultclient, unquote_splicing(margs))
      end
    end
  end
end

defmodule Exredis.Api do
  @moduledoc """
  High-level API
  """

  use Exredis.Api.Helper
  import Exredis, only: [query: 2]

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

  defredis :append, [:key, :value]
  defredis :auth, [:password]
  defredis :bgrewriteaof, []
  defredis :bgsave, []
  defredis :bitcount, [:key]#, :start, :end]
  defredis :bitop, [:operation, :destkey, :key]#, ...]
  defredis :blpop, [:key, :timeout]
  defredis :brpop, [:key, :timeout]
  defredis :brpoplpush, [:source, :destination, :timeout]
  defredis :dbsize, []
  defredis :discard, []
  defredis :dump, [:key]
  defredis :echo, [:message]
  defredis :exec, []
  defredis :exists, [:key]
  defredis :expire, [:key, :seconds]
  defredis :expireat, [:key, :timestamp]
  defredis :flushall, []
  defredis :flushdb, []
  defredis :get, [:key]
  defredis :getbit, [:key, :offset]
  defredis :getrange, [:key, :start, :end]
  defredis :getset, [:key, :value]
  defredis :hdel, [:key, :field]#, ...]
  defredis :hexists, [:key, :field]
  defredis :hget, [:key, :field]
  defredis :hgetall, [:key], fn x ->
    Enum.chunk(x, 2) 
      |> Enum.map(fn [a, b] -> {a, b} end) 
      |> HashDict.new
  end
  defredis :hincrby, [:key, :field, :increment]
  defredis :hincrbyfloat, [:key, :field, :increment]
  defredis :hkeys, [:key]
  defredis :hlen, [:key]
  defredis :hmget, [:key, :field]#, ...]
  defredis :hset, [:key, :field, :value]
  defredis :hsetnx, [:key, :field, :value]
  defredis :hvals, [:key]
  defredis :incr, [:key]
  defredis :incrby, [:key, :increment]
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
  defredis :mget, [:key]#, ...]
  # defredis :migrate
  defredis :monitor, []
  defredis :move, [:key, :db]
  defredis :mset, [:key, :value]#, ...]
  defredis :msetnx, [:key, :value]#, ...]
  defredis :multi, []
  # defredis :object, []
  defredis :persist, [:key]
  defredis :pexpire, [:key, :milliseconds]
  defredis :pexpireat, [:key, :milli_timestamp]
  defredis :ping, []
  defredis :psetex, [:key, :milliseconds, :value]
  defredis :psubscribe, [:pattern]#, ...]
  # defredis :pubsub, [:subcommand]
  defredis :pttl, [:key]
  defredis :publish, [:channel, :message]
  defredis :punsubscribe, [:pattern]#, ...]
  defredis :quit, []
  defredis :randomkey, []
  defredis :rename, [:key, :newkey]
  defredis :renamex, [:key, :newkey]
  defredis :restore, [:key, :ttl, :serialized_value]
  defredis :rpop, [:key]
  defredis :rpoplpush, [:source, :destination]
  defredis :rpush, [:key, :value]#, ...]
  defredis :rpushx, [:key, :value]#, ...]
  defredis :sadd, [:key, :member]#, ...]
  defredis :save, []
  defredis :scard, [:key]
  # defredis :script exists
  # defredis :script flushdb
  # defredis :script kill
  # defredis :script load
  defredis :sdiff, [:key]#, ...]
  defredis :sdiffstore, [:destination, :key]#, ...]
  defredis :select, [:index]
  defredis :set, [:key, :value]#, :seconds, :milli]
  defredis :setbit, [:key, :offset, :value]
  defredis :setex, [:key, :seconds, :value]
  defredis :setnx, [:key, :value]
  defredis :setrange, [:key, :offset, :value]
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
  defredis :strlen, [:key]
  defredis :subscribe, [:channel]#, ...]
  defredis :sunion, [:key]#, ...]
  defredis :sunionstore, [:destination, :key]#, ...]
  defredis :sync, []
  defredis :time, []
  defredis :ttl, [:key]
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

  defp sts_reply("OK"), do:
    :ok

  defp sts_reply(reply), do:
    reply

end
