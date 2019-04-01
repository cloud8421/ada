defmodule Ada.HTTP.Listener do
  def child_spec(ctx) do
    http_port = Keyword.fetch!(ctx, :http_port)

    %{
      id: __MODULE__,
      start:
        {:cowboy, :start_clear,
         [
           __MODULE__,
           [port: http_port],
           %{
             env: %{
               dispatch: Ada.HTTP.Router.dispatch(ctx)
             },
             metrics_callback: &track_metrics/1,
             stream_handlers: [:cowboy_metrics_h, :cowboy_compress_h, :cowboy_stream_h]
           }
         ]},
      type: :worker
    }
  end

  defp track_metrics(cowboy_metrics) do
    duration_us =
      System.convert_time_unit(
        cowboy_metrics.req_end - cowboy_metrics.req_start,
        :native,
        :microsecond
      )

    meta = Map.take(cowboy_metrics, [:resp_status, :req_body_length, :resp_body_length])

    case cowboy_metrics.reason do
      :normal ->
        :telemetry.execute([:http_server, :request, :ok], %{duration: duration_us}, meta)

      _other_reason ->
        :telemetry.execute([:http_server, :request, :error], %{duration: duration_us}, meta)
    end
  end
end
