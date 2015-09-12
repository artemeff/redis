defmodule IntReplyBench do
  use Benchfella

  setup_all do
    {:ok, Exredis.start}
  end

  bench "int_reply", [c: bench_context] do
    c |> Exredis.Api.set "mykey", 42
    c |> Exredis.Api.incr "mykey"
  end
end
