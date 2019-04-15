defmodule Ada.Workflow.SendWeatherForecast do
  @moduledoc false
  @behaviour Ada.Workflow
  alias Ada.Schema.{Location, User}
  alias Ada.Source.Weather
  alias Ada.Email

  @impl true
  def human_name, do: "Send Weather forecast"

  @impl true
  def requirements do
    %{user_id: :integer, location_id: :integer}
  end

  defguard is_present(thing) when not is_nil(thing)

  @impl true
  def fetch(params, ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    with user when is_present(user) <- repo.get(User, params.user_id),
         location when is_present(location) <- repo.get(Location, params.location_id),
         {:ok, weather_report} <- Weather.get(location) do
      {:ok, %{weather_report: weather_report, location: location, user: user}}
    end
  end

  @impl true
  def format(raw_data, :email, _ctx) do
    email_body = Email.Template.weather(raw_data.location.name, raw_data.weather_report)
    {:ok, compose_email(raw_data.user, raw_data.location, email_body)}
  end

  defp compose_email(user, location, email_body) do
    %Email{
      to: [user.email],
      subject: "Weather for #{location.name}",
      body_html: email_body
    }
  end
end
