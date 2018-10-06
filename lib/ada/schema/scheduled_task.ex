defmodule Ada.Schema.ScheduledTask do
  use Ecto.Schema

  @task_version 1

  defmodule Frequency do
    use Ecto.Schema

    embedded_schema do
      field :type, :string, default: "daily"
      field :hour, :integer, default: 0
      field :minute, :integer, default: 0
      field :second, :integer, default: 0
    end
  end

  schema "scheduled_tasks" do
    field :version, :integer, null: false, default: @task_version
    field :workflow_name, Ecto.Module, null: false
    field :params, :map, null: false, default: %{}
    embeds_one :frequency, Frequency

    timestamps()
  end
end
