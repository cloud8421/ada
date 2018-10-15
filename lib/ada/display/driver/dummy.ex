defmodule Ada.Display.Driver.Dummy do
  @behaviour Ada.Display.Driver

  require Logger

  @impl true
  def set_buffer(buffer) do
    Logger.debug(fn ->
      "Dummy Display -> content: #{inspect(buffer)}"
    end)
  end

  @impl true
  def set_brightness(brightness) do
    Logger.debug(fn ->
      "Dummy Display -> set brightness to #{brightness}"
    end)
  end

  @impl true
  def set_default_brightness do
    Logger.debug(fn ->
      "Dummy Display -> set default brightness"
    end)
  end

  @impl true
  def set_zero_brightness do
    set_brightness(0)
  end
end
