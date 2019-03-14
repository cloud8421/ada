defmodule Ada.CLI.FishCompletion do
  # https://gist.github.com/hasit/7f80cfee0d2cc789b75f4aaea40f37e0#file-buffalo-fish

  def render do
    Ada.CLI.commands()
    |> Enum.map(fn command ->
      [
        complete_command(command),
        complete_arguments(command),
        complete_options(command)
      ]
    end)
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp complete_command(command) do
    "complete -xc 'ada' -n '__fish_use_subcommand' -a #{command.name} -d '#{command.description}'"
  end

  defp complete_arguments(command) do
    Enum.map(command.arguments, fn argument ->
      "complete -xc 'ada' -n '__fish_seen_subcommand_from #{command.name}' -a #{argument.name}"
    end)
  end

  defp complete_options(command) do
    Enum.map(command.options, fn option ->
      "complete -xc 'ada' -n '__fish_seen_subcommand_from #{command.name}' -l #{option.name} #{
        complete_aliases(option)
      }"
    end)
  end

  defp complete_aliases(element) do
    element.aliases
    |> Enum.map(fn alias -> "-s #{alias}" end)
    |> Enum.join(" ")
  end
end
