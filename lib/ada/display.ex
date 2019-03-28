defmodule Ada.Display do
  @behaviour :gen_statem

  @default_content ' ADA'

  defstruct driver: Ada.Display.Driver.Dummy,
            brightness: 1,
            content: @default_content

  ################################################################################
  ################################## PUBLIC API ##################################
  ################################################################################

  def start_link(opts) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, opts, [])
  end

  def turn_on do
    :gen_statem.call(__MODULE__, :turn_on)
  end

  def turn_off do
    :gen_statem.call(__MODULE__, :turn_off)
  end

  def set_content(content) do
    :gen_statem.call(__MODULE__, {:set_content, content})
  end

  def set_brightness(brightness) when brightness in 0..255 do
    :gen_statem.call(__MODULE__, {:set_brightness, brightness})
  end

  def get_brightness do
    :gen_statem.call(__MODULE__, :get_brightness)
  end

  ################################################################################
  #################################### UTILS #####################################
  ################################################################################

  defguard is_valid_cycle_spec(cycle_spec) when length(cycle_spec) >= 2

  ################################################################################
  ################################## CALLBACKS ###################################
  ################################################################################

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def callback_mode, do: :state_functions

  def init(opts) do
    driver = Keyword.get(opts, :driver, DummyDriver)

    data = %__MODULE__{driver: driver}

    {:ok, :off, data}
  end

  # OFF

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
