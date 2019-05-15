defmodule Ada.Shortener do
  @moduledoc """
  In-memory URL shortener with automatic expiry (24 hours).

  Cleanup is performed once per hour.
  """

  use GenServer

  require Logger

  alias Ada.{PubSub, Schema.Frequency, Time.Hour}

  @frequency %Frequency{type: "hourly", minute: 0}
  @default_url_lifetime 24 * 60 * 60

  @type url :: String.t()
  @type url_id :: String.t()

  ################################################################################
  ################################## PUBLIC API ##################################
  ################################################################################

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Given a url, returns an ID that can be used to find it.
  """
  @spec shorten(url()) :: url_id()
  def shorten(url) do
    insertion_time = DateTime.utc_now() |> DateTime.to_unix()
    id = Ecto.UUID.generate()
    true = :ets.insert(__MODULE__, {id, insertion_time, url})
    id
  end

  @doc """
  Given a url ID, returns (if available) the corresponding url.
  """
  @spec resolve(url_id()) :: {:ok, url()} | {:error, :not_found}
  def resolve(url_id) do
    case :ets.lookup(__MODULE__, url_id) do
      [{^url_id, _insertion_time, url}] -> {:ok, url}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  Returns the current url lifetime.
  """
  @spec url_lifetime() :: pos_integer()
  def url_lifetime do
    GenServer.call(__MODULE__, :url_lifetime)
  end

  @doc """
  Returns the default url lifetime.
  """
  @spec default_url_lifetime :: pos_integer()
  def default_url_lifetime, do: @default_url_lifetime

  ################################################################################
  ################################## CALLBACKS ###################################
  ################################################################################

  @doc false
  @impl true
  def init(opts) do
    url_lifetime = Keyword.get(opts, :url_lifetime, @default_url_lifetime)
    __MODULE__ = :ets.new(__MODULE__, [:ordered_set, :public, :named_table])
    PubSub.subscribe(Hour)
    {:ok, url_lifetime}
  end

  @doc false
  @impl true
  def handle_call(:url_lifetime, _from, url_lifetime) do
    {:reply, url_lifetime, url_lifetime}
  end

  @doc false
  @impl true
  def handle_info({PubSub.Broadcast, Hour, datetime}, url_lifetime) do
    if Frequency.matches_time?(@frequency, datetime) do
      prune_urls(datetime, url_lifetime)

      {:noreply, url_lifetime}
    end
  end

  defp prune_urls(current_time, url_lifetime) do
    threshold = DateTime.to_unix(current_time) - url_lifetime

    q = [
      {
        {:_, :"$1", :_},
        [{:"=<", :"$1", {:const, threshold}}],
        [true]
      }
    ]

    count = :ets.select_delete(__MODULE__, q)

    Logger.info(fn -> "evt=shortener.prune count=#{count}" end)
  end
end
