defmodule Ada.Workflow.WeatherForecast do
  @behaviour Ada.Workflow
  alias Ada.Schema.{Location, User}
  alias Ada.Source.Weather
  alias Ada.Email

  @impl true
  def human_name, do: "Weather forecast"

  @impl true
  def requirements do
    %{user_id: :integer, location_id: :integer}
  end

  defguard is_present(thing) when not is_nil(thing)

  @impl true
  def run(params, ctx) do
    repo = Keyword.fetch!(ctx, :repo)

    with user when is_present(user) <- repo.get(User, params.user_id),
         location when is_present(location) <- repo.get(Location, params.location_id),
         {:ok, weather_report} <- Weather.get(location),
         email_body = Email.Template.weather(location.name, weather_report),
         email = compose_email(user, location, email_body) do
      Email.ApiClient.send_email(email)
    end
  end

  defp compose_email(user, location, email_body) do
    %Email{
      to: [user.email],
      subject: "Weather for #{location.name}",
      body_html: email_body
    }
  end
end
