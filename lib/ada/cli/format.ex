defmodule Ada.CLI.Format do
  @break "\n"

  def list_users(users) do
    preamble = "==> System users"

    list =
      users
      |> Enum.map(fn user ->
        """
                 ID: #{user.id}
               Name: #{user.name}
              Email: #{user.email}
            Last.fm: #{user.last_fm_username}
        """
      end)
      |> Enum.intersperse(@break)

    :erlang.iolist_to_binary([preamble, @break, @break, list])
  end

  def user_created({:ok, user}) do
    "==> Created User with ID #{user.id}"
  end

  def user_created({:error, changeset}) do
    "==> Error creating user: #{inspect(changeset.errors)}"
  end

  def user_updated({:ok, user}) do
    "==> Updated User with ID #{user.id}"
  end

  def user_updated({:error, changeset}) do
    "==> Error updating user: #{inspect(changeset.errors)}"
  end

  def user_deleted({:ok, user}) do
    "==> Deleted User with ID #{user.id}"
  end

  def user_deleted({:error, changeset}) do
    "==> Error deleting user: #{inspect(changeset.errors)}"
  end

  def brightness_changed(:ok) do
    "==> Brightness updated successfully"
  end

  def brightness_changed(error) do
    "==> Error updating brightness: #{inspect(error)}"
  end

  def location_created({:ok, location}) do
    "==> Created location with ID #{location.id}"
  end

  def location_created({:error, changeset}) do
    "==> Error creating location: #{inspect(changeset.errors)}"
  end

  def scheduled_task_created({:ok, scheduled_task}) do
    "==> Created scheduled_task with ID #{scheduled_task.id}"
  end

  def scheduled_task_created({:error, changeset}) do
    "==> Error creating scheduled_task: #{inspect(changeset.errors)}"
  end
end
