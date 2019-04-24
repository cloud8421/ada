defmodule Ada.CLI.Helpers do
  @moduledoc """
  Provides helper functions to ease the composition of CLI tasks.
  """

  @doc """
  Uses the erlang distribution to connect the CLI node to the device node.
  """
  def connect!(cli_node, target_node) when is_binary(target_node) do
    connect!(cli_node, String.to_atom(target_node))
  end

  def connect!(cli_node, target_node) do
    {:ok, _} = :net_kernel.start([cli_node, :longnames])

    :erlang.set_cookie(
      cli_node,
      String.to_atom("a2g6ek6co44eyahlgfyloqootchaxjuscqh6yf7a2ad63sc2sjiscxynd5wb6k7j")
    )

    true = Node.connect(target_node)
  end

  @doc """
  Only working on Mac, checks for the dependencies needed to infer
  the current location of the machine from the command line.
  """
  def ensure_location_dependencies! do
    case :os.find_executable('CoreLocationCLI') do
      false ->
        IO.puts("""
        Cannot find 'CoreLocationCLI' in path.

        Please install with:

        brew cask install corelocationcli
        """)

        System.halt(1)

      _executable ->
        :ok
    end
  end

  @doc """
  Only working on Mac, returns the current location data.
  """
  def get_current_location_data do
    {data, 0} = System.cmd("CoreLocationCLI", ["-format", "%latitude|%longitude|%address"])

    [lat, lng, address] = String.split(data, "|")

    %{lat: lat, lng: lng, name: address}
  end
end
