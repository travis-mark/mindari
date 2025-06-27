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
    ~p"/onthisday?month=#{prev_month}&day=#{prev_day}"
  end

  @doc """
  Generates a path for the next day navigation.
  """
  def next_day_path(month, day) do
    {next_month, next_day} = next_day(month, day)
    ~p"/onthisday?month=#{next_month}&day=#{next_day}"
  end

  @doc """
  Generates a label for the previous day navigation.
  """
  def previous_day_label(month, day) do
    {prev_month, prev_day} = previous_day(month, day)
    date = Date.new!(Date.utc_today().year, prev_month, prev_day)
    Calendar.strftime(date, "%b %d")
  end

  @doc """
  Generates a label for the next day navigation.
  """
  def next_day_label(month, day) do
    {next_month, next_day} = next_day(month, day)
    date = Date.new!(Date.utc_today().year, next_month, next_day)
    Calendar.strftime(date, "%b %d")
  end

  defp previous_day(month, day) do
    current_year = Date.utc_today().year
    case Date.new(current_year, month, day) do
      {:ok, date} ->
        prev_date = Date.add(date, -1)
        {prev_date.month, prev_date.day}
      {:error, _} ->
        {month, day}
    end
  end

  defp next_day(month, day) do
    current_year = Date.utc_today().year
    case Date.new(current_year, month, day) do
      {:ok, date} ->
        next_date = Date.add(date, 1)
        {next_date.month, next_date.day}
      {:error, _} ->
        {month, day}
    end
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
end