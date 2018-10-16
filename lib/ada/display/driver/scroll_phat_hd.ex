defmodule Ada.Display.Driver.ScrollPhatHD do
  use GenServer
  @behaviour Ada.Display.Driver

  @bus "i2c-1"
  @address 0x74

  @width 17
  @height 7

  @mode_register 0x00
  @frame_register 0x01
  @audiosync_register 0x06
  @shutdown_register 0x0A

  @config_bank 0x0B
  @bank_address 0xFD

  @picture_mode 0x00

  @enable_offset 0x00
  @color_offset 0x24

  defstruct buffer: nil,
            i2c: nil,
            i2c_mod: ElixirALE.I2C,
            current_frame: 0,
            brightness: 1

  # Public API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def set_buffer(buffer) do
    GenServer.call(__MODULE__, {:set_buffer, buffer})
  end

  @impl true
  def set_default_brightness, do: set_brightness(1)

  def set_zero_brightness, do: set_brightness(0)

  @impl true
  def set_brightness(brightness) do
    GenServer.call(__MODULE__, {:set_brightness, brightness})
  end

  # Callbacks

  @impl true
  def init(opts) do
    bus = Keyword.get(opts, :bus, @bus)
    address = Keyword.get(opts, :address, @address)
    i2c_mod = Keyword.get(opts, :i2c_mod, ElixirALE.I2C)
    {:ok, i2c} = i2c_mod.start_link(bus, address)
    reset_i2c(i2c_mod, i2c)
    initialize_display(i2c_mod, i2c)
    buffer = Matrix.new(@width, @height)
    state = show(buffer, %__MODULE__{buffer: buffer, i2c: i2c, i2c_mod: i2c_mod})
    {:ok, state}
  end

  @impl true
  def handle_call({:set_buffer, buffer}, _from, state) do
    new_state =
      buffer
      |> transpose_buffer()
      |> show(state)

    {:reply, :ok, new_state}
  end

  def handle_call({:set_brightness, brightness}, _from, state) do
    new_state = show(state.buffer, %{state | brightness: brightness})
    {:reply, :ok, new_state}
  end

  # Helpers

  defp show(buffer, state) do
    next_frame = next_frame(state.current_frame)

    write_bank(state.i2c_mod, state.i2c, next_frame)

    output =
      buffer
      |> Matrix.scale(state.brightness)
      |> convert_buffer_to_output()

    write_output(state.i2c_mod, state.i2c, output)

    write_config_register(state.i2c_mod, state.i2c, @frame_register, next_frame)

    %{state | buffer: buffer, next_frame: next_frame}
  end

  defp transpose_buffer(buffer) do
    buffer
    |> Enum.map(&Enum.reverse/1)
    |> Matrix.transpose()
  end

  defp reset_i2c(i2c_mod, i2c) do
    write_bank(i2c_mod, i2c, @config_bank)
    i2c_write(i2c_mod, i2c, @shutdown_register, 0)
    Process.sleep(1)
    i2c_write(i2c_mod, i2c, @shutdown_register, 1)
  end

  defp initialize_display(i2c_mod, i2c) do
    # Switch to configuration bank
    write_bank(i2c_mod, i2c, @config_bank)

    # Switch to picture mode
    i2c_write(i2c_mod, i2c, @mode_register, @picture_mode)

    # Disable audio sync
    i2c_write(i2c_mod, i2c, @audiosync_register, 0)

    # Switch to bank 1 (frame 1)
    write_bank(i2c_mod, i2c, 1)
    i2c_write(i2c_mod, i2c, @enable_offset, List.duplicate(255, 18))

    # Switch to bank 0 (frame 0) and enable all LEDs
    write_bank(i2c_mod, i2c, 0)
    i2c_write(i2c_mod, i2c, @enable_offset, List.duplicate(255, 18))
  end

  defp write_bank(i2c_mod, i2c, value) do
    i2c_write(i2c_mod, i2c, @bank_address, value)
  end

  defp write_config_register(i2c_mod, i2c, register, value) do
    write_bank(i2c_mod, i2c, @config_bank)
    i2c_write(i2c_mod, i2c, register, value)
  end

  defp i2c_write(i2c_mod, i2c, address, value) do
    i2c_mod.write(i2c, IO.iodata_to_binary([address, value]))
  end

  defp next_frame(0), do: 1
  defp next_frame(1), do: 0

  defp convert_buffer_to_output(buffer) do
    # our display is 17x7 but the actual controller is designed for a 16x9 display
    # what they did is to take the original display wirings and split them apart and
    # put one on top of another. we need to do some acrobatics to get things working
    for(
      x <- 0..(@width - 1),
      y <- 0..(@height - 1),
      do: {x, y}
    )
    |> Enum.reduce(List.duplicate(0, 144), fn {x, y}, result ->
      List.replace_at(result, pixel_address(x, 6 - y), Matrix.elem(buffer, x, y))
    end)
  end

  defp pixel_address(x, y) when x > 8 do
    x_t = x - 8
    y_t = 6 - (y + 8)
    x_t * 16 + y_t
  end

  defp pixel_address(x, y) do
    x_t = 8 - x
    x_t * 16 + y
  end

  defp write_output(i2c_mod, i2c, output) do
    chunk_size = 32

    output
    |> Enum.chunk_every(chunk_size)
    |> Enum.with_index()
    |> Enum.each(fn {chunks, index} ->
      i2c_write(i2c_mod, i2c, @color_offset + index * chunk_size, chunks)
    end)
  end
end
