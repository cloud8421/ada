defmodule Ada.HTTP.Listener do
  def child_spec(ctx) do
    http_port = Keyword.fetch!(ctx, :http_port)
    repo = Keyword.fetch!(ctx, :repo)

    %{
      id: __MODULE__,
      start:
        {:cowboy, :start_clear,
         [
           __MODULE__,
           [port: http_port],
           %{
             env: %{dispatch: Ada.HTTP.Router.dispatch(repo: repo)}
           }
         ]},
      type: :worker
    }
  end
end
