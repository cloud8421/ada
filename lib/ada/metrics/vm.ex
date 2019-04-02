defmodule Ada.Metrics.Vm do
  @behaviour :vmstats_sink

  def start do
    Application.put_env(:vmstats, :sink, __MODULE__)
    Application.ensure_all_started(:vmstats)
  end

  @impl true
  def collect(type, key, value) do
    key
    |> List.flatten()
    |> Enum.chunk_by(fn i -> i == ?. end)
    |> Enum.filter(fn i -> i not in ['vmstats', '.'] end)
    |> do_collect(type, value)
  end

  defp do_collect(key, type, value) do
    case key do
      [measurement] ->
        :telemetry.execute([:vm, List.to_atom(measurement)], %{value: value}, %{type: type})

      [measurement, field] ->
        :telemetry.execute(
          [:vm, List.to_atom(measurement), List.to_atom(field)],
          %{value: value},
          %{type: type}
        )

      [measurement, scheduler_number, field] ->
        :telemetry.execute(
          [:vm, List.to_atom(measurement), List.to_atom(field)],
          %{value: value},
          %{type: type, scheduler_number: List.to_integer(scheduler_number)}
        )
    end
  end
end
