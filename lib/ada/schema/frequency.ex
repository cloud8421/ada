defmodule Ada.Schema.Frequency do
  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__struct__, :__meta__]}

  embedded_schema do
    field :type, :string, default: "daily"
    field :hour, :integer, default: 0
    field :minute, :integer, default: 0
    field :second, :integer, default: 0
  end

  def changeset(frequency, params) do
    frequency
    |> Ecto.Changeset.cast(params, [:type, :hour, :minute, :second])
    |> Ecto.Changeset.validate_inclusion(:type, ["daily", "hourly"])
    |> Ecto.Changeset.validate_inclusion(:hour, 0..23)
    |> Ecto.Changeset.validate_inclusion(:minute, 0..59)
    |> Ecto.Changeset.validate_inclusion(:second, 0..59)
  end

  def hourly?(frequency), do: frequency.type == "hourly"
  def daily?(frequency), do: frequency.type == "daily"
end
