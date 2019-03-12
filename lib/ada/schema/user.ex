defmodule Ada.Schema.User do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  schema "users" do
    field :name, :string, null: false
    field :email, :string, null: false
    field :last_fm_username, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:name, :email, :last_fm_username])
    |> Ecto.Changeset.validate_required([:name, :email])
  end
end
