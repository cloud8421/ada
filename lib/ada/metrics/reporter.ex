defmodule Ada.Metrics.Reporter do
  @moduledoc false
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = Enum.into(opts, default_state())

    case state.engine.connect() do
      :ok ->
        attach_reporters(state)
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

  defp attach_reporters(state) do
    events = [
      [:vm, :proc_count],
      [:vm, :proc_limit],
      [:vm, :port_count],
      [:vm, :port_limit],
      [:vm, :atom_count],
      [:vm, :messages_in_queues],
      [:vm, :modules],
      [:vm, :run_queue],
      [:vm, :reductions],
      [:vm, :memory, :total],
      [:vm, :memory, :procs_used],
      [:vm, :memory, :atom_used],
      [:vm, :memory, :binary],
      [:vm, :memory, :ets],
      [:vm, :io, :bytes_in],
      [:vm, :io, :bytes_out],
      [:vm, :io, :count],
      [:vm, :io, :words_reclaimed],
      [:vm, :scheduler_wall_time, :active],
      [:vm, :scheduler_wall_time, :total],
      [:http_server, :request, :ok],
      [:http_server, :request, :error],
      [:http_client, :request, :ok],
      [:http_client, :request, :error],
      [:scheduler, :execution, :ok],
      [:scheduler, :execution, :error]
    ]

    :telemetry.attach_many("ada", events, &send_metric/4, state)
  end

  defp send_metric([:vm, measurement], %{value: value}, meta, state) do
    opts = [
      tags: [
        "host:#{state.host}",
        "family:#{state.family}"
      ]
    ]

    send_vm_metric(meta.type, state.engine, "vm_#{measurement}", value, opts)
  end

  defp send_metric([:vm, :scheduler_wall_time, field], %{value: value}, meta, state) do
    opts = [
      tags: [
        "host:#{state.host}",
        "family:#{state.family}",
        "scheduler_number:#{meta.scheduler_number}"
      ]
    ]

    send_vm_metric(meta.type, state.engine, "vm_scheduler_wall_time.#{field}", value, opts)
  end

  defp send_metric([:vm, measurement, field], %{value: value}, meta, state) do
    opts = [
      tags: [
        "host:#{state.host}",
        "family:#{state.family}"
      ]
    ]

    send_vm_metric(meta.type, state.engine, "vm_#{measurement}.#{field}", value, opts)
  end

  defp send_metric([:http_server, :request, result], %{duration: duration}, meta, state) do
    opts = [
      tags: [
        "host:#{state.host}",
        "family:#{state.family}",
        "status:#{meta.resp_status}"
      ]
    ]

    state.engine.timing("http_server.#{result}", to_ms(duration), opts)
    state.engine.gauge("http_server.req_body_size", meta.req_body_length, opts)
    state.engine.gauge("http_server.resp_body_size", meta.resp_body_length, opts)
  end

  defp send_metric([:http_client, :request, result], value, meta, state) do
    case result do
      :ok ->
        opts = [
          tags: [
            "host:#{state.host}",
            "family:#{state.family}",
            "method:#{meta.method}",
            "host:#{meta.host}",
            "status:#{meta.status}"
          ]
        ]

        state.engine.timing("http_client.ok", to_ms(value.duration), opts)
        state.engine.gauge("http_client.size", value.resp_size, opts)

      :error ->
        opts = [
          tags: [
            "host:#{state.host}",
            "family:#{state.family}",
            "method:#{meta.method}",
            "host:#{meta.host}"
          ]
        ]

        state.engine.timing("http_client.error", to_ms(value.duration), opts)
    end
  end

  defp send_metric([:scheduler, :execution, result], %{duration: duration}, meta, state) do
    opts = [
      tags: [
        "host:#{state.host}",
        "family:#{state.family}",
        "workflow:#{workflow_to_tag(meta.workflow)}"
      ]
    ]

    state.engine.timing("scheduler_execution.#{result}", to_ms(duration), opts)
  end

  defp send_metric(_name, _value, _meta, _state), do: :ok

  defp send_vm_metric(type, engine, name, value, opts) do
    case type do
      :counter ->
        engine.increment(name, value, opts)

      :gauge ->
        engine.gauge(name, value, opts)

      :timing ->
        engine.timing(name, value, opts)
    end
  end

  defp to_ms(microseconds), do: System.convert_time_unit(microseconds, :microsecond, :millisecond)

  defp workflow_to_tag(workflow) do
    [_, _, camelcase_name] = Module.split(workflow)

    Macro.underscore(camelcase_name)
  end

  defp default_state do
    %{family: "ada", host: get_hostname()}
  end

  def get_hostname do
    case Application.get_env(:nerves_init_gadget, :mdns_domain) do
      nil ->
        {:ok, hostname_chars} = :inet.gethostname()
        List.to_string(hostname_chars)

      mdns_domain when is_binary(mdns_domain) ->
        mdns_domain
    end
  end
end
