defmodule Ada.CLI.Helpers do
  def connect!(cli_node, target_node) do
    {:ok, _} = :net_kernel.start([cli_node, :longnames])

    :erlang.set_cookie(
      cli_node,
      String.to_atom("a2g6ek6co44eyahlgfyloqootchaxjuscqh6yf7a2ad63sc2sjiscxynd5wb6k7j")
    )

    true = Node.connect(target_node)
  end

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

  def get_current_location_data do
    {data, 0} = System.cmd("CoreLocationCLI", ["-format", "%latitude|%longitude|%address"])

    [lat, lng, address] = String.split(data, "|")

    %{lat: lat, lng: lng, name: address}
  end
end
