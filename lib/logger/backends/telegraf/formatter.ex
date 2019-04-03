defmodule Logger.Backends.Telegraf.Formatter do
  use Bitwise

  def format(level, msg, ts, md, state) do
    %{
      version: version,
      format: format,
      metadata: metadata,
      facility: facility,
      appid: appid,
      hostname: hostname
    } = state

    level_num = level(level)
    allowed_metadata = extract_metadata(md, metadata)

    # we hijack proc_id to act as a correlation id,
    # so if `request_id` is provided in the metadata
    # we use it, otherwise default to the current process pid
    proc_id =
      Keyword.get_lazy(allowed_metadata, :request_id, fn ->
        :erlang.pid_to_list(self())
      end)

    pre =
      :io_lib.format('<~B>~B ~s ~s ~s ~s - ', [
        facility ||| level_num,
        version,
        iso8601_timestamp(ts),
        hostname,
        appid,
        proc_id
      ])

    [
      pre,
      format_metadata(allowed_metadata),
      Logger.Formatter.format(format, level, msg, ts, [])
    ]
  end

  defp extract_metadata(md, :all), do: md
  defp extract_metadata(md, metadata), do: Keyword.take(md, metadata)

  # Lifted from smpallen99/syslog

  def iso8601_timestamp({{year, month, date}, {hour, minute, second, micro}}) do
    :io_lib.format(
      "~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0B.~3..0BZ",
      [year, month, date, hour, minute, second, micro]
    )
    |> to_string
  end

  defp level(:debug), do: 7
  defp level(:info), do: 6
  defp level(:notice), do: 5
  defp level(:warn), do: 4
  defp level(:warning), do: 4
  defp level(:err), do: 3
  defp level(:error), do: 3
  defp level(:crit), do: 2
  defp level(:alert), do: 1
  defp level(:emerg), do: 0
  defp level(:panic), do: 0

  defp level(i) when is_integer(i) when i >= 0 and i <= 7, do: i
  defp level(_bad), do: 3

  # Lifted from Logger.Formatter

  defp format_metadata([]), do: ""

  defp format_metadata(meta) do
    pairs =
      Enum.map(meta, fn {key, val} ->
        [?\s, to_string(key), ?=, ?", metadata(key, val), ?"]
      end)

    ["[meta", pairs, ?], ?\s]
  end

  defp metadata(:initial_call, {mod, fun, arity})
       when is_atom(mod) and is_atom(fun) and is_integer(arity) do
    Exception.format_mfa(mod, fun, arity)
  end

  defp metadata(_, pid) when is_pid(pid) do
    :erlang.pid_to_list(pid)
  end

  defp metadata(_, ref) when is_reference(ref) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    rest
  end

  defp metadata(_, atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> rest
      "nil" -> ""
      binary -> binary
    end
  end

  defp metadata(_, other), do: to_string(other)
end
