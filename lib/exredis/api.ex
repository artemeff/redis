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
  @type v  :: binary | list | :undefined

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

  @spec keys(c, kl) :: blk_reply
  def keys(c, kl), do:
    c |> query(["KEYS", kl])

  @spec pexpire(c, k, v) :: int_reply
  def pexpire(c, k, v), do:
    c |> query(["PEXPIRE", k, v]) |> int_reply

  ##
  # Strings
  ##

  @spec get(c, k) :: str_reply
  def get(c, k), do:
    c |> query(["GET", k])

  @spec set(c, k, v) :: sts_reply
  def set(c, k, v), do:
    c |> query(["SET", k, v]) |> sts_reply

  @spec mset(c, kv) :: sts_reply
  def mset(c, kv), do:
    c |> query(["MSET" | kv]) |> sts_reply

  @spec mget(c, kv) :: v
  def mget(c, kv), do:
    c |> query(["MGET" | kv])

  ##
  # Pub/Sub
  ##

  @spec publish(c, k, v) :: any
  def publish(c, ch, msg), do:
    c |> query(["PUBLISH", ch, msg])

  ##
  # Server
  ##

  @spec flushall(c) :: v
  def flushall(c), do:
    c |> query(["FLUSHALL"])

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
