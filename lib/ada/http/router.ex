defmodule Ada.HTTP.Router do
  def dispatch do
    :cowboy_router.compile([
      {:_, []}
    ])
  end
end
