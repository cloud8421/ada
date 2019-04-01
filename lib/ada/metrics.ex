defmodule Ada.Metrics do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = Enum.into(opts, %{})

    case state.engine.connect() do
      :ok ->
        attach_reporters(state.engine)
        {:ok, state}

      error ->
        log_connection_error(error, state)
        :ignore
    end
  end

  defp log_connection_error(reason, state) do
    Logger.warn(fn ->
      """
      Couldn't start the #{inspect(state.engine)} metrics sink for reason:

      #{inspect(reason)}

      The device will function normally, but its performance metrics will not
      be reported.
      """
    end)
  end

  defp attach_reporters(engine) do
    events = [
      [:http_server, :request, :ok],
      [:http_server, :request, :error],
      [:http_client, :request, :ok],
      [:http_client, :request, :error],
      [:scheduler, :execution, :ok],
      [:scheduler, :execution, :error]
    ]

    :telemetry.attach_many("ada", events, &send_metric/4, engine)
  end

  defp send_metric([:http_server, :request, result], %{duration: duration}, meta, engine) do
    opts = [
      tags: [
        "status:#{meta.resp_status}"
      ]
    ]

    engine.timing("http_server.#{result}", to_ms(duration), opts)
    engine.gauge("http_server.req_body_size", meta.req_body_length, opts)
    engine.gauge("http_server.resp_body_size", meta.resp_body_length, opts)
  end

  defp send_metric([:http_client, :request, result], value, meta, engine) do
    case result do
      :ok ->
        opts = [
          tags: [
            "method:#{meta.method}",
            "host:#{meta.host}",
            "status:#{meta.status}"
          ]
        ]

        engine.timing("http_client.ok", to_ms(value.duration), opts)
        engine.gauge("http_client.size", value.resp_size, opts)

      :error ->
        opts = [
          tags: [
            "method:#{meta.method}",
            "host:#{meta.host}"
          ]
        ]

        engine.timing("http_client.error", to_ms(value.duration), opts)
    end
  end

  defp send_metric([:scheduler, :execution, result], %{duration: duration}, meta, engine) do
    opts = [
      tags: [
        "workflow:#{workflow_to_tag(meta.workflow)}"
      ]
    ]

    engine.timing("scheduler_execution.#{result}", to_ms(duration), opts)
  end

  defp send_metric(_name, _value, _meta, _engine), do: :ok

  defp to_ms(microseconds), do: System.convert_time_unit(microseconds, :microsecond, :millisecond)

  defp workflow_to_tag(workflow) do
    [_, _, camelcase_name] = Module.split(workflow)

    Macro.underscore(camelcase_name)
  end
end
