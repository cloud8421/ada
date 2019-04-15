defmodule Ada.HTTP.Router do
  @moduledoc false
  alias Ada.{HTTP.Handler, Schema}

  def dispatch(opts) do
    ui_path = Keyword.fetch!(opts, :ui_path)

    :cowboy_router.compile([
      {:_,
       [
         {'/locations/[:location_id]/activate', Handler.Location.Activate, opts},
         collection_path('/locations', Schema.Location, opts),
         resource_path('/locations', Schema.Location, opts),
         collection_path('/users', Schema.User, opts),
         resource_path('/users', Schema.User, opts),
         {'/scheduled_tasks/[:scheduled_task_id]/run', Handler.RunScheduledTask, opts},
         collection_path('/scheduled_tasks', Schema.ScheduledTask, opts),
         resource_path('/scheduled_tasks', Schema.ScheduledTask, opts),
         {'/workflows', Handler.Workflows, opts},
         {'/display/brightness', Handler.Display.Brightness, opts},
         {"/", :cowboy_static, {:priv_file, :ada, ui_path ++ '/index.html'}},
         {"/[...]", :cowboy_static, {:priv_dir, :ada, ui_path}}
       ]}
    ])
  end

  defp collection_path(path, schema, opts) do
    {path, Handler.Collection, Keyword.put(opts, :schema, schema)}
  end

  defp resource_path(path, schema, opts) do
    {path ++ '/[:resource_id]', Handler.Resource, Keyword.put(opts, :schema, schema)}
  end
end
