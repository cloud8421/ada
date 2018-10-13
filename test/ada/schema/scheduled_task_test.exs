defmodule Ada.Schema.ScheduledTaskTest do
  use ExUnit.Case, async: true

  alias Ada.Schema.{Frequency, ScheduledTask}

  defmodule TestWorkflow do
    @behaviour Ada.Workflow

    @impl true
    def human_name, do: "Test workflow"

    @impl true
    def requirements, do: %{name: :string}

    @impl true
    def run(params, _ctx) do
      name = Map.fetch!(params, :name)
      String.upcase(name)
    end
  end

  describe "matches_time?/2" do
    test "daily frequency" do
      st = %ScheduledTask{frequency: %Frequency{}}

      assert ScheduledTask.matches_time?(st, ~N[2018-10-06 00:00:00.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 00:00:01.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 01:00:00.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 14:01:00.066161])
    end

    test "hourly frequency" do
      st = %ScheduledTask{
        frequency: %Frequency{type: "hourly", minute: 6, second: 30}
      }

      assert ScheduledTask.matches_time?(st, ~N[2018-10-06 00:06:30.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 04:06:31.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 14:01:30.066161])
      refute ScheduledTask.matches_time?(st, ~N[2018-10-06 06:00:00.066161])
    end
  end

  describe "execute/1" do
    test "it runs the contained workflow" do
      st = %ScheduledTask{workflow_name: TestWorkflow, params: %{name: "Ada"}}

      assert "ADA" == ScheduledTask.execute(st, [])
    end
  end
end
