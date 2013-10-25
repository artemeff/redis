defmodule Exredis.Api do
  @moduledoc """
  High-level API
  """

  import Exredis, only: [query: 2]

  defmacro __using__(_opts) do
    quote do
      import Exredis.Api
    end
  end

  @type c  :: pid
  @type k  :: binary
  @type kl :: k | list
  @type kv :: list
  @type v  :: binary | list | integer | :undefined

  @type sts_reply :: :ok
  @type int_reply :: integer
  @type blk_reply :: list
  @type str_reply :: binary | :undefined
  @type err_reply :: binary

  ##
  # Keys
  ##

  @spec del(c, k) :: int_reply
  def del(c, k), do:
    c |> query(["DEL", k]) |> int_reply

  @spec dump(c, k) :: blk_reply
  def dump(c, k), do:
    c |> query(["DUMP", k])

  @spec exists(c, k) :: int_reply
  def exists(c, k), do:
    c |> query(["EXISTS", k]) |> int_reply

  @spec expire(c, k, v) :: int_reply
  def expire(c, k, v), do:
    c |> query(["EXPIRE", k, v]) |> int_reply

  @spec expireat(c, k, v) :: int_reply
  def expireat(c, k, v), do:
    c |> query(["EXPIREAT", k, v]) |> int_reply

  @spec keys(c, kl) :: blk_reply
  def keys(c, kl), do:
    c |> query(["KEYS", kl])

  # migrate
  # move
  # object

  @spec persist(c, k) :: int_reply
  def persist(c, k), do:
    c |> query(["PERSIST", k]) |> int_reply

  @spec pexpire(c, k, v) :: int_reply
  def pexpire(c, k, v), do:
    c |> query(["PEXPIRE", k, v]) |> int_reply

  @spec pexpireat(c, k, v) :: int_reply
  def pexpireat(c, k, v), do:
    c |> query(["PEXPIREAT", k, v]) |> int_reply

  @spec pttl(c, k) :: int_reply
  def pttl(c, k), do:
    c |> query(["PTTL", k]) |> int_reply

  @spec randomkey(c) :: blk_reply
  def randomkey(c), do:
    c |> query(["RANDOMKEY"])

  @spec rename(c, k, k) :: sts_reply
  def rename(c, k, nk), do:
    c |> query(["RENAME", k, nk]) |> sts_reply

  @spec renamenx(c, k, k) :: int_reply
  def renamenx(c, k, nk), do:
    c |> query(["RENAMENX", k, nk]) |> int_reply

  # restore
  # sort

  @spec ttl(c, k) :: int_reply
  def ttl(c, k), do:
    c |> query(["TTL", k]) |> int_reply

  @spec type(c, k) :: str_reply
  def type(c, k), do:
    c |> query(["TYPE", k])

  ##
  # Strings
  ##

  @spec append(c, k, v) :: int_reply
  def append(c, k, v), do:
    c |> query(["APPEND", k, v]) |> int_reply

  @spec bitcount(c, k) :: int_reply
  def bitcount(c, k), do:
    c |> query(["BITCOUNT", k]) |> int_reply

  @spec bitcount(c, k, v, v) :: int_reply
  def bitcount(c, k, start, bend), do:
    c |> query(["BITCOUNT", k, start, bend]) |> int_reply

  # bitop
  
  @spec decr(c, k) :: int_reply
  def decr(c, k), do:
    c |> query(["DECR", k]) |> int_reply

  @spec decrby(c, k, v) :: int_reply
  def decrby(c, k, v), do:
    c |> query(["DECRBY", k, v]) |> int_reply

  @spec get(c, k) :: str_reply
  def get(c, k), do:
    c |> query(["GET", k])

  @spec getbit(c, k, v) :: int_reply
  def getbit(c, k, offset), do:
    c |> query(["GETBIT", k, offset]) |> int_reply

  @spec getrange(c, k, v, v) :: str_reply
  def getrange(c, k, start, bend), do:
    c |> query(["GETRANGE", k, start, bend])

  @spec getset(c, k, v) :: str_reply
  def getset(c, k, v), do:
    c |> query(["GETSET", k, v])

  @spec incr(c, k) :: int_reply
  def incr(c, k), do:
    c |> query(["INCR", k]) |> int_reply

  @spec incrby(c, k, v) :: int_reply
  def incrby(c, k, by), do:
    c |> query(["INCRBY", k, by]) |> int_reply

  @spec incrbyfloat(c, k, v) :: str_reply
  def incrbyfloat(c, k, by), do:
    c |> query(["INCRBYFLOAT", k, by])

  @spec mget(c, kv) :: blk_reply
  def mget(c, kv), do:
    c |> query(["MGET" | kv])
    
  @spec mset(c, kv) :: sts_reply
  def mset(c, kv), do:
    c |> query(["MSET" | kv]) |> sts_reply

  # msetnx
  # psetex

  @spec set(c, k, v) :: sts_reply
  def set(c, k, v), do:
    c |> query(["SET", k, v]) |> sts_reply

  @spec setbit(c, k, v, v) :: int_reply
  def setbit(c, k, offset, value), do:
    c |> query(["SETBIT", k, offset, value]) |> int_reply

  @spec setex(c, k, v, v) :: sts_reply
  def setex(c, k, exp, value), do:
    c |> query(["SETEX", k, exp, value]) |> sts_reply

  @spec setnx(c, k, v) :: int_reply
  def setnx(c, k, v), do:
    c |> query(["SETNX", k, v]) |> int_reply

  @spec setrange(c, k, v, v) :: int_reply
  def setrange(c, k, at, value), do:
    c |> query(["SETRANGE", k, at, value]) |> int_reply

  @spec strlen(c, k) :: int_reply
  def strlen(c, k), do:
    c |> query(["STRLEN", k]) |> int_reply

  ##
  # Hashes
  ##

  @spec hdel(c, k, v) :: int_reply
  def hdel(c, k, field), do:
    c |> query(["HDEL", k, field]) |> int_reply

  @spec hexists(c, k, v) :: int_reply
  def hexists(c, k, field), do:
    c |> query(["HEXISTS", k, field]) |> int_reply
  
  @spec hget(c, k, v) :: blk_reply
  def hget(c, k, field), do:
    c |> query(["HGET", k, field])
  
  @spec hgetall(c, k) :: blk_reply
  def hgetall(c, k), do:
    c |> query(["HGETALL", k])

  # hincrby
  # hincrbyfloat
  # hkeys
  # hlen
  # hmget
  # hmset
  
  @spec hset(c, k, v, v) :: int_reply
  def hset(c, k, field, value), do:
    c |> query(["HSET", k, field, value]) |> int_reply

  # hsetnx
  # hvals

  ##
  # Lists
  ##

  # blpop
  # btpop
  # brpoplpush
  # lindex
  # linsert
  # llen
  # lpop
  # lpush
  # lpushx
  # lrange
  # lrem
  # lset
  # ltrim
  # rpop
  # rpoplpush
  # rpush
  # rpushx

  ##
  # Sets
  ##

  # sadd
  # scard
  # sdiff
  # sdiffstore
  # sinter
  # sinterstore
  # sismember
  # smembers
  # smove
  # spop
  # srandmember
  # srem
  # sunion
  # sunionstore

  ##
  # Sorted sets
  ##

  # zadd
  # zcard
  # zcount
  # zincrby
  # zinterstore
  # zrange
  # zrangebyscore
  # zrank
  # zrem
  # zremrangebyrank
  # zremrangebyscore
  # zrevrange
  # zrevrangebyscore
  # zrevrank
  # zscore
  # zunionstore

  ##
  # Pub/Sub
  ##

  # psubscribe
  # pubsub

  @spec publish(c, k, v) :: int_reply
  def publish(c, ch, msg), do:
    c |> query(["PUBLISH", ch, msg]) |> int_reply

  # punsubscribe
  # subscribe
  # unsubscribe

  ##
  # Transactions
  ##

  # discard
  # exec
  # multi
  # unwatch
  # watch

  ##
  # Scripting
  ##

  # eval
  # evalsha
  # script exists
  # script flush
  # script kill
  # script load

  ##
  # Connection
  ##

  # auth
  # echo
  # ping
  # quit
  # select

  ##
  # Server
  ##

  # bgrewriteaof
  # bgsave
  # client kill
  # client list
  # client getname
  # client setname
  # config get
  # config rewrite
  # config set
  # config resetstat
  # dbsize
  # debug object
  # debug segfault

  @spec flushall(c) :: sts_reply
  def flushall(c), do:
    c |> query(["FLUSHALL"]) |> sts_reply

  # flushdb
  # info
  # lastsave
  # monitor
  # save
  # shutdown
  # slaveof
  # slowlog
  # sync
  # time

  ##
  # Reply parsers
  ##

  defp int_reply(reply), do:
    reply |> binary_to_integer

  defp sts_reply("OK"), do:
    :ok

  defp sts_reply(reply), do:
    reply

end
