defmodule Ada.Display.Driver do
  @type buffer :: term()

  @callback set_buffer(buffer) :: :ok
  @callback set_default_brightness() :: :ok
  @callback set_zero_brightness() :: :ok
end
