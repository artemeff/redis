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
  @type kv :: list
  @type v  :: binary | list | :undefined

  @type int_reply :: integer

  ##
  # Keys
  ##

  @spec del(c, k) :: v
  def del(c, k), do:
    c |> query ["DEL", k]

  @spec keys(c, k) :: v
  def keys(c, k), do:
    c |> query ["KEYS", k]

  @spec pexpire(c, k, v) :: int_reply
  def pexpire(c, k, v), do:
    c |> query(["PEXPIRE", k, v]) |> int_reply

  ##
  # Strings
  ##

  @spec get(c, k) :: v
  def get(c, k), do:
    c |> query ["GET", k]

  @spec set(c, k, v) :: binary
  def set(c, k, v), do:
    c |> query ["SET", k, v]

  @spec mset(c, kv) :: v
  def mset(c, kv), do:
    c |> query ["MSET" | kv]

  @spec mget(c, kv) :: v
  def mget(c, kv), do:
    c |> query ["MGET" | kv]

  ##
  # Pub/Sub
  ##

  @spec publish(c, k, v) :: any
  def publish(c, ch, msg), do:
    c |> query ["PUBLISH", ch, msg]

  ##
  # Server
  ##

  @spec flushall(c) :: v
  def flushall(c), do:
    c |> query ["FLUSHALL"]

  ##
  # Reply parsers
  ##

  @spec int_reply(binary) :: int_reply
  defp int_reply(reply), do:
    reply |> binary_to_integer

end
