defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch(opts) do
    ui_path = Keyword.fetch!(opts, :ui_path)

    :cowboy_router.compile([
      {:_,
       [
         {'/locations/[:location_id]/activate', Handler.Location.Activate, opts},
         collection_path('/locations', Ada.Schema.Location, opts),
         resource_path('/locations', Ada.Schema.Location, opts),
         collection_path('/users', Ada.Schema.User, opts),
         resource_path('/users', Ada.Schema.User, opts),
         {'/scheduled_tasks/[:scheduled_task_id]/execute', Handler.ExecuteScheduledTask, opts},
         collection_path('/scheduled_tasks', Ada.Schema.ScheduledTask, opts),
         resource_path('/scheduled_tasks', Ada.Schema.ScheduledTask, opts),
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
