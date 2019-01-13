commands_url = 'https://raw.githubusercontent.com/antirez/redis-doc/master/commands.json'

with {:ok, {{_, 200, _}, _headers, body}} <- :httpc.request(commands_url),
     {:ok, term} <- Jason.decode(body)
do
  sorted_term =
    term
    |> Enum.into([])
    |> Enum.sort_by(fn({k, _v}) -> k end)

  binary =
    inspect(sorted_term, pretty: true, limit: :infinity)

  File.write("priv/commands.exs", binary <> "\n")
  File.write("priv/commands.bin", :zlib.gzip(binary))
else
  error ->
    exit(error)
end
