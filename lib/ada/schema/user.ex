defmodule Ada.Schema.User do
  @moduledoc false
  use Ecto.Schema

  schema "users" do
    field :name, :string, null: false
    field :email, :string, null: false
    field :last_fm_username, :string

    timestamps()
  end

  @type t :: %__MODULE__{
          __meta__: term(),
          id: String.t(),
          name: String.t(),
          email: String.t(),
          last_fm_username: Ada.Source.LastFm.username(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @spec changeset(t, map()) :: Ecto.Changeset.t()
  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:name, :email, :last_fm_username])
    |> Ecto.Changeset.validate_required([:name, :email])
  end

  @spec gravatar_url(t) :: String.t()
  def gravatar_url(user) do
    "https://www.gravatar.com/avatar/" <> md5(user.email)
  end

  defp md5(string) do
    :crypto.hash(:md5, string) |> Base.encode16(case: :lower)
  end
end

defimpl Jason.Encoder, for: Ada.Schema.User do
  def encode(user, opts) do
    data =
      user
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Map.put(:gravatar_url, Ada.Schema.User.gravatar_url(user))

    Jason.Encode.map(data, opts)
  end
end
