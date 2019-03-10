defmodule Ada.CLI do
  use ExCLI.DSL, escript: true

  alias Ada.CLI.Format

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
      |> :rpc.call(Ada.Repo, :all, [Ada.Schema.User])
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

      changeset =
        :rpc.call(target_node, Ada.Schema.User, :changeset, [%Ada.Schema.User{}, context])

      target_node
      |> :rpc.call(Ada.Repo, :insert!, [changeset])
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

      user = :rpc.call(target_node, Ada.Repo, :get!, [Ada.Schema.User, context.id])

      :rpc.call(target_node, Ada.Repo, :delete!, [user])
      |> Format.user_deleted()
      |> IO.puts()
    end
  end

  defp connect!(target_node) do
    {:ok, _} = :net_kernel.start([@cli_node, :longnames])

    :erlang.set_cookie(
      :"cli@127.0.0.1",
      String.to_atom("a2g6ek6co44eyahlgfyloqootchaxjuscqh6yf7a2ad63sc2sjiscxynd5wb6k7j")
    )

    true = Node.connect(target_node)
  end
end
