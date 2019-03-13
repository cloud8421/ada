defmodule Ada.CLI do
  use ExCLI.DSL, escript: true

  alias Ada.{CLI.Helpers, CLI.Format, CRUD}

  @default_target_node :"ada@ada.local"
  @cli_node :"cli@127.0.0.1"

  name "ada"
  description "Control a given Ada instance"

  long_description """
  Describe scope of commands.
  Describe node name and cookie requirements.
  """

  command :list_users do
    option :target_node, aliases: [:t]
    aliases [:lsu]
    description "Lists the system users"
    long_description "Lists the system users"

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      target_node
      |> :rpc.call(CRUD, :list, [Ada.Schema.User])
      |> Format.list_users()
      |> IO.puts()
    end
  end

  command :create_user do
    option :target_node, aliases: [:t]
    option(:last_fm_username)
    aliases [:cu]
    description "Creates a new system user"
    long_description "Creates a new system user"

    argument(:name)
    argument(:email)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      target_node
      |> :rpc.call(CRUD, :create, [Ada.Schema.User, context])
      |> Format.user_created()
      |> IO.puts()
    end
  end

  command :update_user do
    option :target_node, aliases: [:t]
    aliases [:uu]
    description "Updates an existing system user"
    long_description "Updates an existing system user"

    argument(:id, type: :integer)
    option(:last_fm_username)
    option(:name)
    option(:email)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      user = :rpc.call(target_node, CRUD, :find, [Ada.Schema.User, context.id])

      target_node
      |> :rpc.call(CRUD, :update, [Ada.Schema.User, user, context])
      |> Format.user_updated()
      |> IO.puts()
    end
  end

  command :delete_user do
    option :target_node, aliases: [:t]
    aliases [:du]
    description "Deletes a system user"
    long_description "Deletes a system user"

    argument(:id, type: :integer)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      user = :rpc.call(target_node, CRUD, :find, [Ada.Schema.User, context.id])

      :rpc.call(target_node, CRUD, :delete, [user])
      |> Format.user_deleted()
      |> IO.puts()
    end
  end

  command :brightness do
    option :target_node, aliases: [:t]
    aliases [:b]
    description "Controls the device brightness"
    long_description "Controls the device brightness"

    argument(:operation)
    option(:intensity, type: :integer)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      current_brightness = :rpc.call(target_node, Ada.Display, :get_brightness, [])

      case context.operation do
        "up" ->
          :rpc.call(target_node, Ada.Display, :set_brightness, [
            inc_brightness(current_brightness, 10)
          ])
          |> Format.brightness_changed()
          |> IO.puts()

        "down" ->
          :rpc.call(target_node, Ada.Display, :set_brightness, [
            dec_brightness(current_brightness, 10)
          ])
          |> Format.brightness_changed()
          |> IO.puts()

        "set" ->
          :rpc.call(target_node, Ada.Display, :set_brightness, [
            context.intensity
          ])
          |> Format.brightness_changed()
          |> IO.puts()

        other ->
          IO.puts("""
          ==> Unsupported option #{other}.

              Valid values are:
              - up
              - down
              - set --intensity <integer-between-0-and-255>
          """)

          System.halt(1)
      end
    end
  end

  command :add_current_location do
    option :target_node, aliases: [:t]
    aliases [:acl]
    description "Adds the current location"

    long_description """
    Adds the current location. Requires CoreLocationCLI to be installed and it may
    prompt for user authorization.
    """

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      Helpers.ensure_location_dependencies!()

      location_attributes = Helpers.get_current_location_data()

      target_node
      |> :rpc.call(CRUD, :create, [Ada.Schema.Location, location_attributes])
      |> Format.location_created()
      |> IO.puts()
    end
  end

  command :create_scheduled_task do
    option :target_node, aliases: [:t]
    aliases [:cst]
    description "Creates a new scheduled task"
    long_description "Creates a new scheduled task"

    argument(:workflow_name)
    argument(:frequency)
    option(:user_id, type: :integer)
    option(:location_id, type: :integer)
    option(:tag)
    option(:interval_in_hours)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      available_workflows = :rpc.call(target_node, Ada.Workflow.Register, :all, [])

      workflow_name = parse_workflow_name(context.workflow_name, available_workflows)
      params = Map.take(context, [:user_id, :location_id, :tag, :interval_in_hours])
      frequency = parse_frequency(context.frequency)

      attributes = %{workflow_name: workflow_name, params: params, frequency: frequency}

      target_node
      |> :rpc.call(CRUD, :create, [Ada.Schema.ScheduledTask, attributes])
      |> Format.scheduled_task_created()
      |> IO.puts()
    end
  end

  defp inc_brightness(brightness, inc) do
    if brightness + inc >= 255, do: 255, else: brightness + inc
  end

  defp dec_brightness(brightness, dec) do
    if brightness - dec <= 1, do: 1, else: brightness - dec
  end

  defp parse_frequency(frequency_string) do
    case String.split(frequency_string, ":") do
      ["hourly", minute] ->
        %{type: "hourly", minute: String.to_integer(minute)}

      ["daily", hour] ->
        %{type: "daily", hour: String.to_integer(hour)}

      ["weekly", day_of_week, hour] ->
        %{
          type: "daily",
          day_of_week: String.to_integer(day_of_week),
          hour: String.to_integer(hour)
        }

      other ->
        IO.puts("""
        ==> Incorrectly formatted frequency value #{other}.

            Allowed values are:

            - hourly:10 (every hour at 10 past)
            - daily:14 (every day at 2pm)
            - weekly:1:15 (every monday at 3pm)
        """)

        System.halt(1)
    end
  end

  defp parse_workflow_name(workflow_name_string, available_workflows) do
    suffix_strings =
      Enum.map(available_workflows, fn aw ->
        [_, _, suffix] = Module.split(aw)

        Macro.underscore(suffix)
      end)

    case workflow_name_string do
      "send_last_fm_report" ->
        Ada.Workflow.SendLastFmReport

      "send_news_by_tag" ->
        Ada.Workflow.SendNewsByTag

      "send_weather_forecast" ->
        Ada.Workflow.SendWeatherForecast

      other ->
        IO.puts("""
        ==> Invalid workflow name #{other}.

            Valid names are: #{inspect(suffix_strings)}
        """)

        System.halt(1)
    end
  end
end
