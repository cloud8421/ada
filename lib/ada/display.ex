defmodule Ada.Display do
  @moduledoc """
  Lower level driver to directly control the contents of the LED screen.
  """

  @behaviour :gen_statem

  defstruct driver: Ada.Display.Driver.Dummy,
            brightness: 1,
            content: nil

  @type duration_ms :: pos_integer()
  @typedoc """
  Represents a specification for a static screen, constantly displaying the
  same contents.

  For example:

      {:static, Ada.UI.Helpers.chars_to_matrix('1234')}
  """
  @type static_spec :: {:static, Ada.Display.Driver.buffer()}

  @typedoc """
  Represents a specification for a cyclic screen, which loops over different
  buffers, each one with a specific duration.

  For example:

      [
        {Ada.UI.Helpers.chars_to_matrix('A   '), 200},
        {Ada.UI.Helpers.chars_to_matrix(' A  '), 200},
        {Ada.UI.Helpers.chars_to_matrix('  A '), 200},
        {Ada.UI.Helpers.chars_to_matrix('   A'), 200}
      ]
  """
  @type cycle_spec :: {:cycle, [{Ada.Display.Driver.buffer(), duration_ms()}]}
  @type content :: static_spec() | cycle_spec()

  ################################################################################
  ################################## PUBLIC API ##################################
  ################################################################################

  @doc false
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(opts) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, opts, [])
  end

  @doc """
  Turn on the screen.
  """
  @spec turn_on() :: :ok
  def turn_on do
    :gen_statem.call(__MODULE__, :turn_on)
  end

  @doc """
  Turn off the screen.
  """
  @spec turn_off() :: :ok
  def turn_off do
    :gen_statem.call(__MODULE__, :turn_off)
  end

  @doc """
  Sets the screen contents.

  Please see `t:static_spec/0` and `t:cycle_spec/0` for information about supported formats.
  """
  @spec set_content(content()) :: :ok | {:error, :cycle_spec_too_short} | no_return()
  def set_content(content) do
    :gen_statem.call(__MODULE__, {:set_content, content})
  end

  @doc """
  Sets the screen brigthness.
  """
  @spec set_brightness(Ada.Display.Driver.brightness()) :: :ok | no_return()
  def set_brightness(brightness) when brightness in 0..255 do
    :gen_statem.call(__MODULE__, {:set_brightness, brightness})
  end

  @doc """
  Gets the screen brigthness.
  """
  @spec get_brightness() :: Ada.Display.Driver.brightness()
  def get_brightness do
    :gen_statem.call(__MODULE__, :get_brightness)
  end

  ################################################################################
  #################################### UTILS #####################################
  ################################################################################

  defguardp is_valid_cycle_spec(cycle_spec) when length(cycle_spec) >= 2

  ################################################################################
  ################################## CALLBACKS ###################################
  ################################################################################

  @doc false
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc false
  def callback_mode, do: :state_functions

  @doc false
  def init(opts) do
    driver = Keyword.get(opts, :driver, DummyDriver)

    data = %__MODULE__{driver: driver, content: driver.default_content()}

    {:ok, :off, data}
  end

  # OFF

  @doc false
  def off({:call, from}, :turn_on, data) do
    :ok = data.driver.set_buffer(data.content)
    :ok = data.driver.set_default_brightness()

    {:next_state, :static, data, {:reply, from, :ok}}
  end

  def off({:call, from}, :turn_off, _data) do
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def off({:call, from}, {:set_brightness, brightness}, data) do
    :ok = data.driver.set_buffer(data.content)
    :ok = data.driver.set_brightness(brightness)
    new_data = %{data | brightness: brightness}

    {:next_state, :static, new_data, {:reply, from, :ok}}
  end

  def off({:call, from}, :get_brightness, data) do
    {:keep_state_and_data, {:reply, from, data.brightness}}
  end

  def off({:call, from}, {:set_content, {:static, buffer}}, data) do
    :ok = data.driver.set_buffer(buffer)
    :ok = data.driver.set_default_brightness()
    new_data = %{data | content: buffer}
    {:next_state, :static, new_data, {:reply, from, :ok}}
  end

  def off({:call, from}, {:set_content, {:cycle, cycle_spec}}, data)
      when is_valid_cycle_spec(cycle_spec) do
    new_data = %{data | content: :queue.from_list(cycle_spec)}
    actions = [{:reply, from, :ok}, {:next_event, :internal, :cycle}]
    {:next_state, :cyclic, new_data, actions}
  end

  def off({:call, from}, {:set_content, {:cycle, _cycle_spec}}, _data) do
    {:keep_state_and_data, {:reply, from, {:error, :cycle_spec_too_short}}}
  end

  # STATIC

  @doc false
  def static({:call, from}, :turn_on, _data) do
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def static({:call, from}, :turn_off, data) do
    :ok = data.driver.set_brightness(0)
    new_data = %{data | brightness: 0}
    {:next_state, :off, new_data, {:reply, from, :ok}}
  end

  def static({:call, from}, {:set_brightness, brightness}, data) do
    :ok = data.driver.set_brightness(brightness)
    new_data = %{data | brightness: brightness}
    {:keep_state, new_data, {:reply, from, :ok}}
  end

  def static({:call, from}, :get_brightness, data) do
    {:keep_state_and_data, {:reply, from, data.brightness}}
  end

  def static({:call, from}, {:set_content, {:static, buffer}}, data) do
    :ok = data.driver.set_buffer(buffer)
    new_data = %{data | content: buffer}
    {:keep_state, new_data, {:reply, from, :ok}}
  end

  def static({:call, from}, {:set_content, {:cycle, cycle_spec}}, data)
      when is_valid_cycle_spec(cycle_spec) do
    new_data = %{data | content: :queue.from_list(cycle_spec)}
    actions = [{:reply, from, :ok}, {:next_event, :internal, :cycle}]
    {:next_state, :cyclic, new_data, actions}
  end

  def static({:call, from}, {:set_content, {:cycle, _cycle_spec}}, _data) do
    {:keep_state_and_data, {:reply, from, {:error, :cycle_spec_too_short}}}
  end

  # CYCLIC

  @doc false
  def cyclic(event_type, :cycle, data)
      when event_type in [:internal, :state_timeout] do
    {{:value, {buffer, duration} = spec_item}, remaining_spec} = :queue.out(data.content)
    :ok = data.driver.set_buffer(buffer)
    new_data = %{data | content: :queue.in(spec_item, remaining_spec)}
    action = {:state_timeout, duration, :cycle}
    {:keep_state, new_data, action}
  end

  def cyclic({:call, from}, :turn_on, _data) do
    {:keep_state_and_data, {:reply, from, :ok}}
  end

  def cyclic({:call, from}, :turn_off, data) do
    :ok = data.driver.set_brightness(0)
    new_data = %{data | brightness: 0}
    {:next_state, :off, new_data, {:reply, from, :ok}}
  end

  def cyclic({:call, from}, {:set_brightness, brightness}, data) do
    :ok = data.driver.set_brightness(brightness)
    new_data = %{data | brightness: 0}
    {:keep_state, new_data, {:reply, from, :ok}}
  end

  def cyclic({:call, from}, :get_brightness, data) do
    {:keep_state_and_data, {:reply, from, data.brightness}}
  end

  def cyclic({:call, from}, {:set_content, {:static, buffer}}, data) do
    :ok = data.driver.set_buffer(buffer)
    new_data = %{data | content: buffer}
    {:next_state, :static, new_data, {:reply, from, :ok}}
  end

  def cyclic({:call, from}, {:set_content, {:cycle, cycle_spec}}, data)
      when is_valid_cycle_spec(cycle_spec) do
    new_data = %{data | content: :queue.from_list(cycle_spec)}
    actions = [{:reply, from, :ok}, {:next_event, :internal, :cycle}]
    {:keep_state, new_data, actions}
  end

  def cyclic({:call, from}, {:set_content, {:cycle, _cycle_spec}}, _data) do
    {:keep_state_and_data, {:reply, from, {:error, :cycle_spec_too_short}}}
  end
end
