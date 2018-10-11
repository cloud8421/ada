defmodule Ecto.Module do
  @behaviour Ecto.Type

  def type, do: :string

  def cast(value) when is_atom(value), do: {:ok, value}

  def cast("Elixir." <> _rest = mod_name) do
    {:ok, String.to_existing_atom(mod_name)}
  end

  def cast(mod_name_without_prefix) when is_binary(mod_name_without_prefix) do
    {:ok, String.to_existing_atom("Elixir." <> mod_name_without_prefix)}
  end

  def cast(_), do: :error

  def load(value), do: {:ok, String.to_existing_atom(value)}

  def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
  def dump(_), do: :error
end
