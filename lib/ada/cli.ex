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

  defp inc_brightness(brightness, inc) do
    if brightness + inc >= 255, do: 255, else: brightness + inc
  end

  defp dec_brightness(brightness, dec) do
    if brightness - dec <= 1, do: 1, else: brightness - dec
  end
end
