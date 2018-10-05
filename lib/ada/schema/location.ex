defmodule Ada.Schema.Location do
  use Ecto.Schema

  schema "locations" do
    field :name, :string, null: false
    field :lat, :float, null: false
    field :lng, :float, null: false

    timestamps()
  end
end
