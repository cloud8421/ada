defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch(opts) do
    :cowboy_router.compile([
      {:_,
       [
         {'/locations', Handler.Locations, opts},
         {'/locations/[:location_id]', Handler.Location, opts}
       ]}
    ])
  end
end
