defmodule Ecto.ETF do
  @moduledoc false
  @behaviour Ecto.Type

  # See http://erlang.org/doc/apps/erts/erl_ext_dist.html#id95128
  # for details about ETF.
  #
  # For safety reasons, decompression is done with the :safe flag.

  def type, do: :binary

  def cast(binary = <<131, _::binary>>) do
    try do
      {:ok, :erlang.binary_to_term(binary, [:safe])}
    catch
      _ ->
        {:ok, binary}
    end
  end

  def cast(any), do: {:ok, any}

  def load(any), do: cast(any)

  def dump(any), do: {:ok, :erlang.term_to_binary(any)}
end
