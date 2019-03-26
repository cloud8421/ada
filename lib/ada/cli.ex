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

  command :update_scheduled_task do
    option :target_node, aliases: [:t]
    aliases [:ust]
    description "Updates an existing scheduled task"
    long_description "Updates an existing scheduled task"

    argument(:id, type: :integer)
    option(:frequency)
    option(:user_id, type: :integer)
    option(:location_id, type: :integer)
    option(:tag)
    option(:email)
    option(:interval_in_hours, type: :integer)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      scheduled_task = :rpc.call(target_node, CRUD, :find, [Ada.Schema.ScheduledTask, context.id])

      params =
        case Map.take(context, [:user_id, :location_id, :tag, :interval_in_hours]) do
          map when map_size(map) == 0 -> %{}
          non_empty_params -> %{params: Map.merge(scheduled_task.params, non_empty_params)}
        end

      frequency =
        case Map.get(context, :frequency) do
          nil -> %{}
          frequency_string -> %{frequency: parse_frequency(frequency_string)}
        end

      attributes = Map.merge(frequency, params)

      target_node
      |> :rpc.call(CRUD, :update, [Ada.Schema.ScheduledTask, scheduled_task, attributes])
      |> Format.scheduled_task_updated()
      |> IO.puts()
    end
  end

  command :list_scheduled_tasks do
    option :target_node, aliases: [:t]
    aliases [:lst]
    description "Lists configured scheduled task"
    long_description "Lists configured scheduled tasks"

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      users = :rpc.call(target_node, CRUD, :list, [Ada.Schema.User])
      locations = :rpc.call(target_node, CRUD, :list, [Ada.Schema.Location])
      scheduled_tasks = :rpc.call(target_node, CRUD, :list, [Ada.Schema.ScheduledTask])

      scheduled_tasks
      |> Format.list_scheduled_tasks(users, locations)
      |> IO.puts()
    end
  end

  command :run_scheduled_task do
    option :target_node, aliases: [:t]
    aliases [:rst]
    description "Runs the specified scheduled task"
    long_description "Runs the specifed scheduled task"

    argument(:id, type: :integer)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      scheduled_task = :rpc.call(target_node, CRUD, :find, [Ada.Schema.ScheduledTask, context.id])

      target_node
      |> :rpc.call(Ada.Scheduler, :run_one_sync, [scheduled_task])
      |> Format.scheduled_task_result()
      |> IO.puts()
    end
  end

  command :preview_scheduled_task do
    option :target_node, aliases: [:t]
    aliases [:pst]
    description "Previews the specified scheduled task"
    long_description "Previews the specifed scheduled task"

    argument(:id, type: :integer)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      scheduled_task = :rpc.call(target_node, CRUD, :find, [Ada.Schema.ScheduledTask, context.id])

      target_node
      |> :rpc.call(Ada.Scheduler, :preview, [scheduled_task])
      |> Format.preview(scheduled_task)
      |> IO.puts()
    end
  end

  command :set_preference do
    option :target_node, aliases: [:t]
    description "Sets a preference on the device"
    long_description "Sets a preference on the device"

    argument(:preference_name)
    argument(:preference_value)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      preference_name = parse_preference_name(context.preference_name)

      :ok =
        :rpc.call(target_node, Ada.Preferences, :set, [preference_name, context.preference_value])

      IO.puts("Preference #{context.preference_name} updated to #{context.preference_value}")
    end
  end

  command :pull_db do
    option :target_node, aliases: [:t]
    description "Pull a copy of the system database"
    long_description "Pull a copy of the system database"

    option(:target_file)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      target_file =
        Map.get_lazy(context, :target_file, fn ->
          now = DateTime.utc_now() |> DateTime.to_iso8601()
          "ada-v1-#{now}.db"
        end)

      Helpers.connect!(@cli_node, target_node)

      repo_config = :rpc.call(target_node, Ada.Repo, :config, [])
      db_file_path = repo_config[:database]

      db_file_contents = :rpc.call(target_node, File, :read!, [db_file_path])

      File.write!(target_file, db_file_contents)

      IO.puts("DB file written at #{target_file}")
    end
  end

  command :push_db do
    option :target_node, aliases: [:t]
    description "Restore the device system database from a local copy"
    long_description "Restore the device system database from a local copy"

    argument(:source_file)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      source_file_contents = File.read!(context.source_file)

      repo_config = :rpc.call(target_node, Ada.Repo, :config, [])
      db_file_path = repo_config[:database]

      :ok = :rpc.call(target_node, File, :write!, [db_file_path, source_file_contents])

      :ok = :rpc.call(target_node, Application, :stop, [:ada])

      :ok = :rpc.call(target_node, Application, :ensure_all_started, [:ranch])
      :ok = :rpc.call(target_node, Application, :ensure_all_started, [:ada])

      IO.puts("DB file pushed")
    end
  end

  command :backup_db do
    option :target_node, aliases: [:t]
    description "Backs up the device database with the configured strategy"
    long_description "Backs up the device database with the configured strategy"

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      Helpers.connect!(@cli_node, target_node)

      {:ok, path} = :rpc.call(target_node, Ada.Backup.Uploader, :save_now, [])

      IO.puts("Backup file saved at #{path}")
    end
  end

  command :fish_autocomplete do
    description "Generate autocomplete rules for the Fish shell"

    long_description """
    Generate autocomplete rules for the Fish shell

    Load with: ada fish_autocomplete | source
    """

    run _context do
      Ada.CLI.FishCompletion.render()
      |> IO.puts()
    end
  end

  def commands, do: @app.commands

  defp inc_brightness(brightness, inc) do
    if brightness + inc >= 255, do: 255, else: brightness + inc
  end

  defp dec_brightness(brightness, dec) do
    if brightness - dec <= 1, do: 1, else: brightness - dec
  end

  @splitter ~r(\:|\.)
  defp parse_frequency(frequency_string) do
    case String.split(frequency_string, @splitter) do
      ["hourly", minute] ->
        %{type: "hourly", minute: String.to_integer(minute)}

      ["daily", hour, minute] ->
        %{type: "daily", hour: String.to_integer(hour), minute: String.to_integer(minute)}

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
            - daily:14.30 (every day at 2.30pm)
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

  defp parse_preference_name(name_string) do
    case name_string do
      "timezone" ->
        :timezone

      other ->
        IO.puts("""
        ==> Invalid preference name #{other}.

            Valid names are: ["timezone"].
        """)

        System.halt(1)
    end
  end
end
