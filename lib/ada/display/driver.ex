defmodule Ada.Display.Driver do
  @moduledoc """
  This behaviour represents a generic display driver, which needs to be
  implemented when supporting a new LED display or similar.
  """

  @typedoc """
  A data structure representing the contents of the display.
  """
  @type buffer :: Matrix.matrix()

  @typedoc """
  Represents the brigthness of the display, from low (1) to high (255).
  """
  @type brightness :: 1..255

  @doc """
  Returns the buffer that should be set when the display is turned on.
  """
  @callback default_content :: buffer()

  @doc """
  Synchronously set the current buffer, so that it can be displayed.
  """
  @callback set_buffer(buffer) :: :ok

  @doc """
  Sets the default brightness that's used when the display is turned on.
  """
  @callback set_default_brightness() :: :ok

  @doc """
  Synchronously set the current brightness, so that the display can be updated.
  """
  @callback set_brightness(brightness) :: :ok
end
