defmodule Ada.HTTP.Router do
  alias Ada.HTTP.Handler

  def dispatch do
    :cowboy_router.compile([
      {:_,
       [
         {'/locations', Handler.Locations, []}
       ]}
    ])
  end
end
