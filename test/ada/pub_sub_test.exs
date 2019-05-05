defmodule Ada.PubSubTest do
  use ExUnit.Case, async: true

  alias Ada.PubSub

  test "subscribe and receive events" do
    assert :ok == PubSub.subscribe(:test_topic)
    assert :ok == PubSub.publish(:test_topic, 1)

    assert_receive {PubSub.Broadcast, :test_topic, 1}
  end
end
