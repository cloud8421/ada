defmodule Ada.Preferences do
  @moduledoc """
  Control system wide preferences.
  """

  alias Ada.{Repo, Schema.Preference}
  import Ecto.Query

  @names [:timezone]

  @doc false
  defguard is_valid_name(name) when name in @names

  @doc false
  defguard is_valid_pair(name, value)
           when is_valid_name(name) and is_binary(value)

  @doc """
  Loads default values in the database without overwriting already
  existing entries.
  """
  @spec load_defaults! :: [Preference.t()]
  def load_defaults! do
    defaults()
    |> Enum.map(fn {name, value} when is_valid_pair(name, value) ->
      Preference.changeset(%Preference{}, %{name: name, value: value})
    end)
    |> Enum.map(fn changeset -> Repo.insert!(changeset, on_conflict: :nothing) end)
  end

  @doc """
  Returns all existing preferences as tuples.
  """
  @spec all :: [{Preference.name(), Preference.value()}]
  def all do
    q =
      from p in Preference,
        select: {p.name, p.value}

    Repo.all(q)
  end

  @doc """
  Returns the value of a given preference.
  """
  @spec get(Preference.name()) :: Preference.value()
  def get(name) when is_valid_name(name) do
    Repo.get(Preference, name).value
  end

  @doc """
  Sets the value of a given preference.
  """
  @spec set(Preference.name(), Preference.value()) :: :ok
  def set(name, value) when is_valid_pair(name, value) do
    current_preference = Repo.get(Preference, name)
    changeset = Preference.changeset(current_preference, %{value: value})

    Repo.update!(changeset)
    Ada.PubSub.publish(Ada.Preference, {name, value})
  end

  @doc """
  Safely cast a preference name to its atom form.
  """
  @spec cast(String.t()) :: {:ok, Preference.name()} | {:error, :invalid_preference_name}
  for name <- @names do
    name_string = to_string(name)
    def cast(unquote(name_string)), do: {:ok, unquote(name)}
  end

  def cast(_unsupported_name), do: {:error, :invalid_preference_name}

  defp defaults do
    Application.get_env(:ada, :default_preferences, [])
  end
end
