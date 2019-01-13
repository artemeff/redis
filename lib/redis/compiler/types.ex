defmodule Redis.Compiler.Types do
  @moduledoc false

  @optional_nil :__optional_nil__

  # custom

  def as_is(val) do
    val
  end

  # generic

  def optional(opts, key) do
    Keyword.get(opts, key, @optional_nil)
  end

  def close(@optional_nil) do
    []
  end
  def close(value) do
    [" ", string(value)]
  end

  def multiple(value, name, validator \\ nil)

  def multiple(@optional_nil, _name, _validator) do
    @optional_nil
  end
  def multiple([], name, _validator) do
    raise ArgumentError, "#{name} required"
  end
  def multiple(values, _name, validator) when is_list(values) and is_function(validator, 1) do
    values |> Enum.map(validator) |> join()
  end
  def multiple(values, _name, nil) when is_list(values) do
    values |> join()
  end
  def multiple(value, _name, validator) when is_function(validator, 1) do
    validator.(value)
  end
  def multiple(value, _name, nil) do
    value
  end

  def variadic(@optional_nil, _name, _keys) do
    @optional_nil
  end
  def variadic(values, _name, _keys) do
    join(values)
  end
  # TODO support variadic arguments
  # def variadic(values, _name, keys) when length(values) == length(keys) do
  #   join(values)
  # end
  # def variadic(value, name, keys) do
  #   raise ArgumentError, "#{name} should have same length as the key"
  # end

  def command(@optional_nil, _command) do
    @optional_nil
  end
  def command(value, "expiration") do
    value
  end
  def command(value, prefix) do
    [prefix, " ", string(value)]
  end

  def enum_atom([], _key, _accepts) do
    @optional_nil
  end
  def enum_atom(opts, key, accepts) when is_list(opts) do
    case Enum.find(accepts, fn({k, _}) -> Enum.member?(opts, k) end) do
      {_enum_key, value} -> value
      nil -> opts |> optional(key) |> enum(key, accepts)
    end
  end
  def enum_atom(opts, key, _accepts) do
    raise ArgumentError, "#{key} expects list of options, but #{inspect(opts)} provided"
  end

  def enum(@optional_nil, _key, _accepts) do
    @optional_nil
  end
  def enum(value, _key, accepts) when is_function(accepts, 1) do
    accepts.(value)
  end
  # fix for `EX seconds | PX milliseconds`
  def enum({exp, value}, :expiration = key, accepts) do
    case Map.fetch(accepts, exp) do
      {:ok, prefix} ->
        [prefix, " ", string(value)]

      :error ->
        raise ArgumentError, accepts_error(key, value, accepts)
    end
  end
  def enum(value, key, accepts) do
    case Map.fetch(accepts, value) do
      {:ok, value} ->
        string(value)

      :error ->
        raise ArgumentError, accepts_error(key, value, accepts)
    end
  end

  def tuple(@optional_nil, _name, _length) do
    @optional_nil
  end
  def tuple(value, _name, length) when is_tuple(value) and tuple_size(value) == length do
    value |> Tuple.to_list |> Enum.map(&string/1) |> join()
  end
  def tuple(value, name, length) do
    raise ArgumentError, tuple_error(name, value, length)
  end

  defp join(values) do
    Enum.reduce(Enum.reverse(values), [], fn
      (val, []) -> [val]
      (val, tl) -> [val, " " | tl]
    end)
  end

  def string(value) when is_binary(value) or is_list(value) do
    value
  end
  def string(value) do
    to_string(value)
  end

  ### errors

  defp accepts_error(name, value, accepts) do
    show_accepts =
      accepts
      |> Map.keys
      |> Enum.map(&display/1)
      |> Enum.join(", ")

    "#{name} accepts #{show_accepts}, but #{inspect(value)} provided"
  end

  defp tuple_error(name, value, length) do
    raise ArgumentError,
      "#{name} should be tuple of #{length} elements, " <>
      "but got #{inspect(value)}"
  end

  defp display(v) when is_binary(v), do: v
  defp display(v), do: inspect(v)
end
