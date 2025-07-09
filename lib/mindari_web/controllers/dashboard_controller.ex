defmodule MindariWeb.DashboardController do
  use MindariWeb, :controller

  def index(conn, _params) do
    # Get current date for "On This Day" stats
    {{_year, month, day}, _time} = :calendar.local_time()
    today_notes = Mindari.Obsidian.get_notes_for_date(month, day)
    
    # Get this month's stats
    month_notes = get_month_notes(month)
    
    # Generate dashboard data
    dashboard_data = %{
      today_notes_count: length(today_notes),
      month_notes_count: length(month_notes),
      recent_activity: generate_recent_activity(today_notes),
      stats: generate_stats(month_notes)
    }

    conn
    |> assign(:page_title, "Dashboard")
    |> assign(:dashboard_data, dashboard_data)
    |> render(:index)
  end

  defp get_month_notes(month) do
    # Get all notes for the current month across all days
    1..31
    |> Enum.flat_map(fn day ->
      try do
        Mindari.Obsidian.get_notes_for_date(month, day)
      rescue
        _ -> []
      end
    end)
  end

  defp generate_recent_activity(today_notes) do
    activities = [
      %{
        text: "Accessed On This Day",
        time: "Today",
        type: "access"
      }
    ]

    # Add recent note activities
    note_activities = today_notes
    |> Enum.take(2)
    |> Enum.map(fn note ->
      %{
        text: "Found note: #{note.title}",
        time: "Today",
        type: "note"
      }
    end)

    activities ++ note_activities
  end

  defp generate_stats(month_notes) do
    total_notes = length(month_notes)
    
    %{
      total_notes: total_notes,
      this_week: min(total_notes, 3),
      active_days: min(total_notes, 7),
      total_words: total_notes * 150, # Rough estimate
      avg_note_length: if(total_notes > 0, do: 150, else: 0),
      longest_streak: min(total_notes, 5)
    }
  end
end