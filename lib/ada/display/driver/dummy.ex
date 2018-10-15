defmodule Ada.Display.Driver.Dummy do
  require Logger

  def set_buffer(buffer) do
    Logger.debug(fn ->
      "Dummy Display -> content: #{inspect(buffer)}"
    end)
  end

  def set_default_brightness do
    Logger.debug(fn ->
      "Dummy Display -> set default brightness"
    end)
  end

  def set_zero_brightness do
    Logger.debug(fn ->
      "Dummy Display -> set zero brightness"
    end)
  end
end
