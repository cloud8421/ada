defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch(opts) do
    :cowboy_router.compile([
      {:_,
       [
         {'/locations', Handler.Locations, opts},
         {'/locations/[:location_id]', Handler.Location, opts},
         {'/users', Handler.Users, opts},
         {'/users/[:user_id]', Handler.User, opts},
         {'/scheduled_tasks', Handler.ScheduledTasks, opts},
         {'/scheduled_tasks/[:scheduled_task_id]', Handler.ScheduledTask, opts},
         {"/", :cowboy_static, {:priv_file, :ada, 'static/web-ui/index.html'}},
         {"/[...]", :cowboy_static, {:priv_dir, :ada, 'static/web-ui'}}
       ]}
    ])
  end
end
