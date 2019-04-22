defmodule Ada.CLI.Format.Users do
  alias Ada.CLI.Markup

  def format_users(users) do
    [
      Markup.break(),
      Markup.title("Users"),
      Markup.break(),
      Enum.map(users, &format_user/1)
    ]
  end

  def format_user(user) do
    [
      Markup.h1("ID: #{user.id}"),
      Markup.list_item("Name", user.name),
      Markup.list_item("Email", user.email),
      Markup.list_item("Last.fm", user.last_fm_username || "not set"),
      Markup.break()
    ]
  end
end
