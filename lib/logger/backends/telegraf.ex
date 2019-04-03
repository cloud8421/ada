defmodule Logger.Backends.Telegraf do
  @moduledoc """
  Telegraf compatible, syslog formatted Logger backend.

  Derived from smpallen99/syslog: Elixir logger syslog backend
  at <https://github.com/smpallen99/syslog>.
  """

  @behaviour :gen_event

  alias Logger.Backends.Telegraf.Formatter

  use Bitwise

  def init(_) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      {:ok, socket} = :gen_udp.open(0)
      {:ok, configure(socket: socket)}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end

    {:ok, state}
  end

  ## Helpers

  defp configure(options, state \\ %{}) do
    config = Keyword.merge(Application.get_env(:logger, __MODULE__, []), options)
    socket = Keyword.get(options, :socket, Map.get(state, :socket))
    Application.put_env(:logger, __MODULE__, config)

    format =
      config
      |> Keyword.get(:format)
      |> Logger.Formatter.compile()

    level = Keyword.get(config, :level)
    version = Keyword.get(config, :version, 1)
    metadata = Keyword.get(config, :metadata, [])
    host = Keyword.get(config, :host, '127.0.0.1')
    port = Keyword.get(config, :port, 514)
    facility = Keyword.get(config, :facility, :local2) |> facility()
    appid = Keyword.get(config, :appid, :elixir)
    [hostname | _] = String.split("#{:net_adm.localhost()}", ".")

    %{
      format: format,
      metadata: metadata,
      level: level,
      version: version,
      socket: socket,
      host: host,
      port: port,
      facility: facility,
      appid: appid,
      hostname: hostname
    }
  end

  defp log_event(level, msg, ts, md, state) do
    %{host: host, port: port, socket: socket} = state
    packet = Formatter.format(level, msg, ts, md, state)

    if(socket, do: :gen_udp.send(socket, host, port, packet))
  end

  defp facility(:local0), do: 16 <<< 3
  defp facility(:local1), do: 17 <<< 3
  defp facility(:local2), do: 18 <<< 3
  defp facility(:local3), do: 19 <<< 3
  defp facility(:local4), do: 20 <<< 3
  defp facility(:local5), do: 21 <<< 3
  defp facility(:local6), do: 22 <<< 3
  defp facility(:local7), do: 23 <<< 3
end
