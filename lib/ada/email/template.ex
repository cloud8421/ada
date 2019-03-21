defmodule Ada.Email.Template do
  require EEx

  @templates_path Path.join([Path.expand(__DIR__), "templates"])
  @style_css_file Path.join([:code.priv_dir(:ada), "static", "email", "main.css"])
  @external_resource @style_css_file
  @style_css File.read!(@style_css_file)

  EEx.function_from_file(:def, :layout_template, Path.join(@templates_path, "layout.html.eex"), [
    :style,
    :title,
    :content
  ])

  EEx.function_from_file(
    :def,
    :weather_template,
    Path.join(@templates_path, "weather.html.eex"),
    [:summary, :data_points]
  )

  EEx.function_from_file(
    :def,
    :stories_template,
    Path.join(@templates_path, "stories.html.eex"),
    [:stories]
  )

  EEx.function_from_file(
    :def,
    :last_fm_report_template,
    Path.join(@templates_path, "last_fm_report.html.eex"),
    [:tracks]
  )

  def weather(location_name, report) do
    layout_template(
      @style_css,
      "Weather for #{location_name}",
      weather_template(report.summary, report.data_points)
    )
  end

  def news(source_name, stories) do
    layout_template(@style_css, "News for #{source_name}", stories_template(stories))
  end

  def last_fm_report(report_name, tracks, timezone) do
    tracks_in_local_time = Enum.map(tracks, fn t -> shift_to_local_time(t, timezone) end)
    layout_template(@style_css, report_name, last_fm_report_template(tracks_in_local_time))
  end

  defp format_weather_datetime(datetime) do
    hour =
      datetime.hour
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    minute =
      datetime.minute
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{hour}:#{minute}"
  end

  defp shift_to_local_time(track, timezone) do
    Map.update!(track, :listened_at, fn
      :now_playing -> :now_playing
      utc_listened_at -> Calendar.DateTime.shift_zone!(utc_listened_at, timezone)
    end)
  end

  defp format_listened_at(:now_playing), do: "Now playing"

  defp format_listened_at(datetime) do
    DateTime.to_iso8601(datetime)
  end
end
