defmodule Ada.CLI do
  use ExCLI.DSL, escript: true

  alias Ada.{CLI.Format, CRUD}

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

      connect!(target_node)

      target_node
      |> :rpc.call(CRUD, :list, [Ada.Schema.User])
      |> Format.list_users()
      |> IO.puts()
    end
  end

  command :create_user do
    option :target_node, aliases: [:t]
    aliases [:cu]
    description "Creates a new system user"
    long_description "Creates a new system user"

    argument(:name)
    argument(:email)

    run context do
      target_node = Map.get(context, :target_node, @default_target_node)

      connect!(target_node)

      target_node
      |> :rpc.call(CRUD, :create, [Ada.Schema.User, context])
      |> Format.user_created()
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

      connect!(target_node)

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

      connect!(target_node)

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
      end
    end
  end

  defp connect!(target_node) do
    {:ok, _} = :net_kernel.start([@cli_node, :longnames])

    :erlang.set_cookie(
      @cli_node,
      String.to_atom("a2g6ek6co44eyahlgfyloqootchaxjuscqh6yf7a2ad63sc2sjiscxynd5wb6k7j")
    )

    true = Node.connect(target_node)
  end

  defp inc_brightness(brightness, inc) do
    if brightness + inc >= 255, do: 255, else: brightness + inc
  end

  defp dec_brightness(brightness, dec) do
    if brightness - dec <= 1, do: 1, else: brightness - dec
  end
end
