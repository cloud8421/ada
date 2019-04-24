defmodule Ada.Schema.Preference do
  @moduledoc """
  A preference is a pair of key, value settings which
  affect the behaviour of the entire application.

  One example is the preferred timezone.
  """
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}
  @primary_key {:name, Ecto.Atom, autogenerate: false}

  schema "preferences" do
    field :value, :string, null: false

    timestamps()
  end

  @type t :: %__MODULE__{
          __meta__: term(),
          name: nil | atom(),
          value: nil | String.t(),
          inserted_at: nil | DateTime.t(),
          updated_at: nil | DateTime.t()
        }

  @doc """
  Returns a changeset, starting from a preference and a map of attributes to change.
  """
  @spec changeset(t, map()) :: Ecto.Changeset.t()
  def changeset(preference, params \\ %{}) do
    preference
    |> Ecto.Changeset.cast(params, [:name, :value])
    |> Ecto.Changeset.validate_required([:name, :value])
  end
end
