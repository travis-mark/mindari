defmodule MindariWeb.OnThisDayController do
  use MindariWeb, :controller

  def index(conn, params) do
    {month, day} = parse_date_params(params)
    notes = Mindari.Obsidian.get_notes_for_date(month, day)

    render(conn, :index, notes: notes, month: month, day: day, page_title: "On This Day")
  end

  defp parse_date_params(%{"month" => month_str, "day" => day_str}) do
    month = String.to_integer(month_str)
    day = String.to_integer(day_str)
    {month, day}
  end

  defp parse_date_params(_params) do
    # Use system local date - this will use the system's timezone
    {{_year, month, day}, _time} = :calendar.local_time()
    {month, day}
  end
end
