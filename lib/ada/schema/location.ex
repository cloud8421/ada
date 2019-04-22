defmodule Ada.Schema.Location do
  @moduledoc false
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  schema "locations" do
    field :name, :string, null: false
    field :lat, :float, null: false
    field :lng, :float, null: false
    field :active, :boolean, default: false

    timestamps()
  end

  @type t :: %__MODULE__{
          __meta__: term(),
          id: String.t(),
          name: String.t(),
          lat: float(),
          lng: float(),
          active: bool,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @spec changeset(t, map()) :: Ecto.Changeset.t()
  def changeset(location, params \\ %{}) do
    location
    |> Ecto.Changeset.cast(params, [:name, :lat, :lng])
    |> Ecto.Changeset.validate_required([:name, :lat, :lng])
  end

  @spec activate_changeset(t) :: Ecto.Changeset.t()
  def activate_changeset(location) do
    Ecto.Changeset.change(location, %{active: true})
  end
end
