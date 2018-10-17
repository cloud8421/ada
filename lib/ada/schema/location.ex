defmodule Ada.Schema.Location do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  schema "locations" do
    field :name, :string, null: false
    field :lat, :float, null: false
    field :lng, :float, null: false
    field :active, :boolean, default: false

    timestamps()
  end

  def changeset(location, params \\ %{}) do
    location
    |> Ecto.Changeset.cast(params, [:name, :lat, :lng])
    |> Ecto.Changeset.validate_required([:name, :lat, :lng])
  end
end
