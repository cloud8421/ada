defmodule Ada.HTTP.Listener do
  def child_spec(port) do
    %{
      id: __MODULE__,
      start:
        {:cowboy, :start_clear,
         [
           __MODULE__,
           [port: port],
           %{
             env: %{dispatch: Ada.HTTP.Router.dispatch()}
           }
         ]},
      type: :worker
    }
  end
end
