defmodule Ada.PubSub do
  def child_spec(_opts) do
    Registry.child_spec(keys: :duplicate, name: Ada.PubSub)
  end

  def subscribe(topic) do
    Registry.register(__MODULE__, topic, [])
  end

  def publish(topic, message) do
    Registry.dispatch(__MODULE__, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {Ada.PubSub.Broadcast, topic, message})
    end)
  end
end
