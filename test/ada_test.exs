defmodule AdaTest do
  use ExUnit.Case
  doctest Ada

  test "greets the world" do
    assert Ada.hello() == :world
  end
end
