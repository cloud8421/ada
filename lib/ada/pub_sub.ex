defmodule Ada.PubSub do
  @moduledoc """
  Provides a single-node pub-sub infrastructure on top of `Registry`.

  It needs to be added to the application supervision tree:

      children = [
        Ada.PubSub
      ]

  See `subscribe/1` and `publish/2` for usage details.
  """

  @doc false
  def child_spec(_opts) do
    Registry.child_spec(keys: :duplicate, name: Ada.PubSub)
  end

  @doc """
  Subscribes a process to a topic. The process will receive messages
  in the shape of `{:Ada.PubSub.Broadcast, topic, message}`.
  """
  @spec subscribe(Registry.key()) :: :ok
  def subscribe(topic) do
    {:ok, _} = Registry.register(__MODULE__, topic, [])
    :ok
  end

  @doc """
  Publishes a message for a given topic.
  """
  @spec publish(Registry.key(), term()) :: :ok
  def publish(topic, message) do
    Registry.dispatch(__MODULE__, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {Ada.PubSub.Broadcast, topic, message})
    end)
  end
end
