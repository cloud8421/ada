defmodule Ada.Schema.User do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  schema "users" do
    field :name, :string, null: false
    field :email, :string, null: false

    timestamps()
  end

  def initial_changeset(params \\ %{}) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(params, [:name, :email])
    |> Ecto.Changeset.validate_required([:name, :email])
  end

  def update_changeset(location, params) do
    location
    |> Ecto.Changeset.cast(params, [:name, :email])
    |> Ecto.Changeset.validate_required([:name, :email])
  end
end
