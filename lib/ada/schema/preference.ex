defmodule Ada.Schema.Preference do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}
  @primary_key {:name, Ecto.Atom, autogenerate: false}

  schema "preferences" do
    field :value, :string, null: false

    timestamps()
  end

  def changeset(preference, params \\ %{}) do
    preference
    |> Ecto.Changeset.cast(params, [:name, :value])
    |> Ecto.Changeset.validate_required([:name, :value])
  end
end
