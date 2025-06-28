defmodule Mindari.Obsidian do
  @moduledoc """
  Module for reading and parsing Obsidian vault markdown files.
  """

  @vault_path "/Users/travis/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"

  defmodule Note do
    @moduledoc """
    Struct representing an Obsidian note.
    """
    defstruct [:title, :date, :content, :content_html, :file_path]
  end

  def get_notes_for_date(month, day) do
    notes = @vault_path
    |> get_all_markdown_files()
    |> Enum.filter(fn file_path -> file_matches_date?(file_path, month, day) end)
    |> Enum.map(fn file_path -> parse_note_full(file_path) end)
    
    # Sort by the full date (year-month-day) in descending order
    Enum.sort(notes, fn note1, note2 ->
      date1 = parse_date_for_sorting(note1.date)
      date2 = parse_date_for_sorting(note2.date)
      Date.compare(date1, date2) == :gt
    end)
  end

  defp get_all_markdown_files(vault_path) do
    case File.exists?(vault_path) do
      true ->
        Path.wildcard("#{vault_path}/**/*.md")
        |> Enum.filter(&File.regular?/1)

      false ->
        []
    end
  end

  defp file_matches_date?(file_path, month, day) do
    case File.read(file_path) do
      {:ok, content} ->
        {frontmatter, _markdown_content} = parse_frontmatter(content)
        case Map.get(frontmatter, "date") do
          nil -> false
          date_str -> date_matches?(date_str, month, day)
        end
      {:error, _} ->
        false
    end
  end

  defp date_matches?(date_str, month, day) do
    case parse_date_string(date_str) do
      {:ok, parsed_date} ->
        parsed_date.month == month && parsed_date.day == day
      :error ->
        false
    end
  end

  defp parse_note_full(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        {frontmatter, markdown_content} = parse_frontmatter(content)
        title = extract_title(file_path, markdown_content)
        
        %Note{
          title: title,
          date: Map.get(frontmatter, "date"),
          content: markdown_content,
          content_html: markdown_to_html(markdown_content),
          file_path: file_path
        }

      {:error, _} ->
        %Note{
          title: Path.basename(file_path, ".md"),
          date: nil,
          content: "",
          content_html: "",
          file_path: file_path
        }
    end
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/^---\s*$/m, parts: 3) do
      ["", yaml_content, markdown_content] ->
        frontmatter = parse_yaml(yaml_content)
        {frontmatter, String.trim(markdown_content)}

      [markdown_content] ->
        {%{}, String.trim(markdown_content)}

      _ ->
        {%{}, String.trim(content)}
    end
  end

  defp parse_yaml(yaml_content) do
    yaml_content
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        [key, value] ->
          key = String.trim(key)
          value = String.trim(value)
          Map.put(acc, key, value)

        _ ->
          acc
      end
    end)
  end

  defp extract_title(file_path, content) do
    # Try to get title from first H1 header
    case Regex.run(~r/^#\s+(.+)$/m, content) do
      [_, title] -> String.trim(title)
      _ -> Path.basename(file_path, ".md")
    end
  end

  def markdown_to_html(markdown) do
    # Simple markdown to HTML conversion with dark theme styling
    markdown
    |> String.replace(~r/^#\s+(.+)$/m, "<h1 class=\"text-2xl font-bold text-gray-100 mb-4\">\\1</h1>")
    |> String.replace(~r/^##\s+(.+)$/m, "<h2 class=\"text-xl font-semibold text-gray-200 mb-3\">\\1</h2>")
    |> String.replace(~r/^###\s+(.+)$/m, "<h3 class=\"text-lg font-medium text-gray-300 mb-2\">\\1</h3>")
    |> String.replace(~r/\*\*(.+?)\*\*/m, "<strong class=\"font-semibold text-gray-100\">\\1</strong>")
    |> String.replace(~r/\*(.+?)\*/m, "<em class=\"italic text-gray-300\">\\1</em>")
    |> String.replace(~r/\[([^\]]+)\]\(([^)]+)\)/m, "<a href=\"\\2\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">\\1 <span class=\"text-xs\">↗</span></a>")
    |> String.replace(~r/\[\[([^\]]+)\]\]/m, "<a href=\"obsidian://open?vault=Vault&file=\\1\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" style=\"color: #a855f7; text-decoration: underline;\" data-obsidian-link=\"\\1\">\\1</a>")
    |> String.replace(~r/^- (.+)$/m, "<li class=\"text-gray-300 mb-1 ml-4\">\\1</li>")
    |> String.replace(~r/\[x\]/m, "<span class=\"text-green-400\">✓</span>")
    |> String.replace(~r/\[ \]/m, "<span class=\"text-gray-500\">☐</span>")
    |> String.replace(~r/\n\n/m, "</p><p class=\"text-gray-300 mb-4 leading-relaxed\">")
    |> (&("<p class=\"text-gray-300 mb-4 leading-relaxed\">" <> &1 <> "</p>")).()
    |> String.replace("<p class=\"text-gray-300 mb-4 leading-relaxed\"></p>", "")
    |> String.replace(~r/<li class="text-gray-300 mb-1 ml-4">(.+?)<\/li>/m, "<ul class=\"list-disc list-inside mb-4 space-y-1\"><li class=\"text-gray-300 mb-1 ml-4\">\\1</li></ul>")
  end


  defp parse_date_string(date_str) when is_binary(date_str) do
    date_str = String.trim(date_str)

    # Try various date formats
    formats = [
      # ISO format with time: 2023-12-25T16:49 or 2023-12-25T16:49:00
      ~r/^(\d{4})-(\d{1,2})-(\d{1,2})(T[\d:]+)?$/,
      # ISO format: 2023-12-25
      ~r/^(\d{4})-(\d{1,2})-(\d{1,2})$/,
      # US format: 12/25/2023
      ~r/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/,
      # EU format: 25/12/2023  
      ~r/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/,
      # Date with month name: December 25, 2023
      ~r/^(\w+)\s+(\d{1,2}),?\s+(\d{4})$/,
      # Short format: Dec 25, 2023
      ~r/^(\w+)\s+(\d{1,2}),?\s+(\d{4})$/
    ]

    try_parse_formats(date_str, formats)
  end

  defp try_parse_formats(date_str, [format | rest]) do
    case Regex.run(format, date_str) do
      [_, part1, part2, part3] ->
        parse_date_parts(format, part1, part2, part3, date_str, rest)

      [_, part1, part2, part3, _time_part] ->
        # Handle ISO format with time - ignore the time part
        parse_date_parts(format, part1, part2, part3, date_str, rest)

      nil ->
        try_parse_formats(date_str, rest)
    end
  end

  defp try_parse_formats(_date_str, []), do: :error

  defp parse_date_parts(_format, part1, part2, part3, date_str, rest) do
    iso_format = ~r/^(\d{4})-(\d{1,2})-(\d{1,2})/
    us_format = ~r/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
    
    cond do
      Regex.match?(iso_format, date_str) ->
        create_date(String.to_integer(part1), String.to_integer(part2), String.to_integer(part3))

      Regex.match?(us_format, date_str) ->
        create_date(String.to_integer(part3), String.to_integer(part1), String.to_integer(part2))

      true ->
        # Month name formats
        case month_name_to_number(part1) do
          {:ok, month_num} ->
            create_date(String.to_integer(part3), month_num, String.to_integer(part2))

          :error ->
            try_parse_formats(date_str, rest)
        end
    end
  end

  defp create_date(year, month, day) do
    case Date.new(year, month, day) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> :error
    end
  end

  defp parse_date_for_sorting(date_str) when is_binary(date_str) do
    case parse_date_string(date_str) do
      {:ok, date} -> date
      :error -> ~D[1900-01-01]  # Default date for unparseable dates
    end
  end

  defp parse_date_for_sorting(_), do: ~D[1900-01-01]

  defp month_name_to_number(month_str) do
    month_map = %{
      "january" => 1, "jan" => 1,
      "february" => 2, "feb" => 2,
      "march" => 3, "mar" => 3,
      "april" => 4, "apr" => 4,
      "may" => 5,
      "june" => 6, "jun" => 6,
      "july" => 7, "jul" => 7,
      "august" => 8, "aug" => 8,
      "september" => 9, "sep" => 9, "sept" => 9,
      "october" => 10, "oct" => 10,
      "november" => 11, "nov" => 11,
      "december" => 12, "dec" => 12
    }

    case Map.get(month_map, String.downcase(month_str)) do
      nil -> :error
      month_num -> {:ok, month_num}
    end
  end
end