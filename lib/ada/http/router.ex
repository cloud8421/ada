defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch(opts) do
    :cowboy_router.compile([
      {:_,
       [
         collection_path('/locations', Ada.Schema.Location, opts),
         resource_path('/locations', Ada.Schema.Location, opts),
         collection_path('/users', Ada.Schema.User, opts),
         resource_path('/users', Ada.Schema.User, opts),
         collection_path('/scheduled_tasks', Ada.Schema.ScheduledTask, opts),
         resource_path('/scheduled_tasks', Ada.Schema.ScheduledTask, opts),
         {'/workflows', Handler.Workflows, opts},
         {"/", :cowboy_static, {:priv_file, :ada, 'static/web-ui/index.html'}},
         {"/[...]", :cowboy_static, {:priv_dir, :ada, 'static/web-ui'}}
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
