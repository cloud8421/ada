defmodule Ada.CLI.Format do
  def list_users(users) do
    users
    |> Enum.map(fn user ->
      """
      ID: #{user.id}
      Name: #{user.name}
      Email: #{user.email}
      """
    end)
    |> Enum.intersperse("----\n")
    |> :erlang.iolist_to_binary()
  end

  def user_created(user) do
    "Created User with ID #{user.id}"
  end

  def user_deleted(user) do
    "Deleted User with ID #{user.id}"
  end
end
