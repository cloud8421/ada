defmodule Ada.Preferences do
  @moduledoc false
  alias Ada.{Repo, Schema.Preference}
  import Ecto.Query

  @names [:timezone]

  defguard is_valid_pair(name, value)
           when name in @names and is_binary(value)

  def load_defaults! do
    defaults()
    |> Enum.map(fn {name, value} when is_valid_pair(name, value) ->
      Preference.changeset(%Preference{}, %{name: name, value: value})
    end)
    |> Enum.map(fn changeset -> Repo.insert!(changeset, on_conflict: :nothing) end)
  end

  def all do
    q =
      from p in Preference,
        select: {p.name, p.value}

    Repo.all(q)
  end

  def get(name) when name in @names do
    Repo.get(Preference, name).value
  end

  def set(name, value) when is_valid_pair(name, value) do
    current_preference = Repo.get(Preference, name)
    changeset = Preference.changeset(current_preference, %{value: value})

    Repo.update!(changeset)
    Ada.PubSub.publish(Ada.Preference, {name, value})
  end

  defp defaults do
    Application.get_env(:ada, :default_preferences, [])
  end
end
