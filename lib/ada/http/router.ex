defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch(opts) do
    :cowboy_router.compile([
      {:_,
       [
         {'/locations', Handler.Collection, Keyword.put(opts, :schema, Ada.Schema.Location)},
         {'/locations/[:resource_id]', Handler.Resource,
          Keyword.put(opts, :schema, Ada.Schema.Location)},
         {'/users', Handler.Collection, Keyword.put(opts, :schema, Ada.Schema.User)},
         {'/users/[:resource_id]', Handler.Resource, Keyword.put(opts, :schema, Ada.Schema.User)},
         {'/scheduled_tasks', Handler.Collection,
          Keyword.put(opts, :schema, Ada.Schema.ScheduledTask)},
         {'/scheduled_tasks/[:resource_id]', Handler.Resource,
          Keyword.put(opts, :schema, Ada.Schema.ScheduledTask)},
         {'/workflows', Handler.Workflows, opts},
         {"/", :cowboy_static, {:priv_file, :ada, 'static/web-ui/index.html'}},
         {"/[...]", :cowboy_static, {:priv_dir, :ada, 'static/web-ui'}}
       ]}
    ])
  end
end
