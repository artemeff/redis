Code.require_file "test_helper.exs", __DIR__

defmodule BenchmarkTest do
  use ExUnit.Case, async: true
  alias Exredis, as: E
  alias Exredis.Sub, as: S
  alias Exredis.Api, as: R
  require Benchmark

  # TODO write benchmarks
  
  # setup do
  #   client = E.start
  # 
  #   # clean up database and set test value
  #   client |> E.query ["FLUSHALL"]
  #   client |> E.query ["SET", "key", "value"]
  # 
  #   { :ok, [c: client] }
  # end

  # teardown ctx, do:
  #   ctx[:c] |> E.stop


  # test "get", c do
  #   Benchmark.times 10000, do: c[:c] |> R.get "key"
  # end

end
