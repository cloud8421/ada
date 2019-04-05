defmodule Ada.Display.Driver do
  @type buffer :: term()
  @type brightness :: 1..255

  @callback default_content :: buffer()
  @callback set_buffer(buffer) :: :ok
  @callback set_default_brightness() :: :ok
  @callback set_brightness(brightness) :: :ok
end
