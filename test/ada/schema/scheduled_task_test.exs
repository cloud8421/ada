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
    test "weekly frequency" do
      st = %ScheduledTask{
        frequency: %Frequency{type: "weekly", day_of_week: 5, hour: 9}
      }

      # Local time is Europe London, so we declare an hour in advance
      assert ScheduledTask.matches_time?(st, to_local(~N[2018-10-05 08:00:00.066161]))
      assert ScheduledTask.matches_time?(st, to_local(~N[2018-10-12 08:00:00.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-05 00:00:00.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 01:00:00.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 14:01:00.066161]))
    end

    test "daily frequency" do
      st = %ScheduledTask{frequency: %Frequency{}}

      # Local time is Europe London, so we declare an hour in advance
      assert ScheduledTask.matches_time?(st, to_local(~N[2018-10-05 23:00:00.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 00:00:01.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 01:00:00.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 14:01:00.066161]))
    end

    test "hourly frequency" do
      st = %ScheduledTask{
        frequency: %Frequency{type: "hourly", minute: 6, second: 30}
      }

      assert ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 00:06:30.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 04:06:31.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 14:01:30.066161]))
      refute ScheduledTask.matches_time?(st, to_local(~N[2018-10-06 06:00:00.066161]))
    end
  end

  describe "run/1" do
    test "it runs the contained workflow" do
      st = %ScheduledTask{workflow_name: TestWorkflow, params: %{name: "Ada"}}

      assert "ADA" == ScheduledTask.run(st, [])
    end
  end

  defp to_local(naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.DateTime.shift_zone!("Europe/London")
  end
end
