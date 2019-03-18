defmodule Ada.Backup do
  def run do
    repo_config = Ada.Repo.config()
    db_file = repo_config[:database]

    now = DateTime.utc_now() |> DateTime.to_iso8601()
    file_name = "#{now}/ada-v1.db"

    Ada.Backup.DropboxClient.upload_file(file_name, File.read!(db_file))
  end
end
