defmodule MindariWeb.OnThisDayHTML do
  @moduledoc """
  This module contains pages rendered by OnThisDayController.
  """
  use MindariWeb, :html

  embed_templates "on_this_day_html/*"

  @doc """
  Generates a path for the previous day navigation.
  """
  def previous_day_path(month, day) do
    {prev_month, prev_day} = previous_day(month, day)
    ~p"/then?month=#{prev_month}&day=#{prev_day}"
  end

  @doc """
  Generates a path for the next day navigation.
  """
  def next_day_path(month, day) do
    {next_month, next_day} = next_day(month, day)
    ~p"/then?month=#{next_month}&day=#{next_day}"
  end

  @doc """
  Generates a label for the previous day navigation.
  """
  def previous_day_label(month, day) do
    {prev_month, prev_day} = previous_day(month, day)
    {{current_year, _, _}, _} = :calendar.local_time()
    date = Date.new!(current_year, prev_month, prev_day)
    Calendar.strftime(date, "%b %d")
  end

  @doc """
  Generates a label for the next day navigation.
  """
  def next_day_label(month, day) do
    {next_month, next_day} = next_day(month, day)
    {{current_year, _, _}, _} = :calendar.local_time()
    date = Date.new!(current_year, next_month, next_day)
    Calendar.strftime(date, "%b %d")
  end

  defp previous_day(month, day) do
    {{current_year, _, _}, _} = :calendar.local_time()

    case Date.new(current_year, month, day) do
      {:ok, date} ->
        prev_date = Date.add(date, -1)
        {prev_date.month, prev_date.day}

      {:error, _} ->
        {month, day}
    end
  end

  defp next_day(month, day) do
    {{current_year, _, _}, _} = :calendar.local_time()

    case Date.new(current_year, month, day) do
      {:ok, date} ->
        next_date = Date.add(date, 1)
        {next_date.month, next_date.day}

      {:error, _} ->
        {month, day}
    end
  end

  @doc """
  Removes H1 tags from content that duplicate the note title.
  """
  def clean_content_html(content_html, note_title) do
    # Remove H1 tags that contain the same text as the note title
    content_html
    |> String.replace(~r/<h1[^>]*>#{Regex.escape(note_title)}<\/h1>/i, "")
    |> String.replace(~r/<h1[^>]*>#\s*#{Regex.escape(note_title)}<\/h1>/i, "")
  end

  @doc """
  Generates an Obsidian URI to open a note file in the Obsidian app.
  """
  def obsidian_uri(file_path) do
    # Extract the vault name and note path relative to the vault
    vault_base = "/Users/travis/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"

    case String.starts_with?(file_path, vault_base) do
      true ->
        # Get the relative path from the vault root
        relative_path = String.replace_prefix(file_path, vault_base <> "/", "")
        # Remove the .md extension for Obsidian
        note_name = String.replace_suffix(relative_path, ".md", "")
        # URL encode the note name
        encoded_note = URI.encode(note_name)

        "obsidian://open?vault=Vault&file=#{encoded_note}"

      false ->
        # Fallback for files outside the expected vault path
        file_name = Path.basename(file_path, ".md")
        encoded_name = URI.encode(file_name)
        "obsidian://open?vault=Vault&file=#{encoded_name}"
    end
  end

  @doc """
  Generates calendar data for the current month.
  """
  def calendar_data(month, day) do
    {{current_year, _, _}, _} = :calendar.local_time()
    {{_, today_month, today_day}, _} = :calendar.local_time()
    {:ok, today} = Date.new(current_year, today_month, today_day)

    case Date.new(current_year, month, 1) do
      {:ok, first_day} ->
        days_in_month = Date.days_in_month(first_day)
        start_weekday = Date.day_of_week(first_day, :sunday)

        %{
          month: month,
          year: current_year,
          month_name: Calendar.strftime(first_day, "%B"),
          days_in_month: days_in_month,
          start_weekday: start_weekday,
          current_day: day,
          today: today
        }

      {:error, _} ->
        %{
          month: today.month,
          year: today.year,
          month_name: Calendar.strftime(today, "%B"),
          days_in_month: Date.days_in_month(today),
          start_weekday: Date.day_of_week(Date.new!(today.year, today.month, 1), :sunday),
          current_day: today.day,
          today: today
        }
    end
  end

  @doc """
  Generates path for previous month navigation.
  """
  def previous_month_path(month, _day) do
    {prev_month, _prev_year} = previous_month(month)
    # Use day 1 for month navigation
    ~p"/then?month=#{prev_month}&day=1"
  end

  @doc """
  Generates path for next month navigation.
  """
  def next_month_path(month, _day) do
    {next_month, _next_year} = next_month(month)
    # Use day 1 for month navigation
    ~p"/then?month=#{next_month}&day=1"
  end

  defp previous_month(month) do
    {{current_year, _, _}, _} = :calendar.local_time()

    if month == 1 do
      {12, current_year - 1}
    else
      {month - 1, current_year}
    end
  end

  defp next_month(month) do
    {{current_year, _, _}, _} = :calendar.local_time()

    if month == 12 do
      {1, current_year + 1}
    else
      {month + 1, current_year}
    end
  end

  @doc """
  Formats the date for display with day-of-week, month, day-of-month, year format.
  """
  def formatted_date(month, day) do
    {{current_year, _, _}, _} = :calendar.local_time()
    case Date.new(current_year, month, day) do
      {:ok, date} ->
        Calendar.strftime(date, "%A, %B %d, %Y")
      {:error, _} ->
        "Invalid date"
    end
  end

  @doc """
  Formats an entry date string for display.
  """
  def formatted_entry_date(date_string) do
    cond do
      # Handle datetime format like "2025-07-14T17:02"
      String.contains?(date_string, "T") ->
        [date_part | _] = String.split(date_string, "T")
        case Date.from_iso8601(date_part) do
          {:ok, date} ->
            Calendar.strftime(date, "%A, %B %d, %Y")
          {:error, _} ->
            date_string
        end

      # Handle date-only format like "2025-07-14"
      true ->
        case Date.from_iso8601(date_string) do
          {:ok, date} ->
            Calendar.strftime(date, "%A, %B %d, %Y")
          {:error, _} ->
            date_string
        end
    end
  end

  @doc """
  Generates a list of calendar days with their properties.
  """
  def calendar_days(calendar_data) do
    %{
      month: month,
      days_in_month: days_in_month,
      start_weekday: start_weekday,
      current_day: current_day,
      today: today
    } = calendar_data

    # Add empty days for the start of the month
    empty_days = for _ <- 1..(start_weekday - 1), do: nil

    # Add actual days
    month_days =
      for day <- 1..days_in_month do
        is_today = today.month == month && today.day == day
        is_current = day == current_day

        %{
          day: day,
          is_current: is_current,
          is_today: is_today && !is_current,
          path: ~p"/then?month=#{month}&day=#{day}"
        }
      end

    empty_days ++ month_days
  end
end
