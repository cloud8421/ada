defmodule Ada.Repo.Migrations.UpdateWorkflowNamesForEmail do
  use Ecto.Migration

  import Ecto.Query

  def up do
    q =
      from st in Ada.Schema.ScheduledTask,
        where: st.workflow_name == ^Ada.Workflow.WeatherForecast

    Ada.Repo.update_all(q, set: [workflow_name: Ada.Workflow.SendWeatherForecast])

    q = from st in Ada.Schema.ScheduledTask, where: st.workflow_name == ^Ada.Workflow.NewsByTag

    Ada.Repo.update_all(q, set: [workflow_name: Ada.Workflow.SendNewsByTag])
  end

  def down do
    q =
      from st in Ada.Schema.ScheduledTask,
        where: st.workflow_name == ^Ada.Workflow.SendWeatherForecast

    Ada.Repo.update_all(q, set: [workflow_name: Ada.Workflow.WeatherForecast])

    q =
      from st in Ada.Schema.ScheduledTask, where: st.workflow_name == ^Ada.Workflow.SendNewsByTag

    Ada.Repo.update_all(q, set: [workflow_name: Ada.Workflow.NewsByTag])
  end
end
