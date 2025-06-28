defmodule Mindari.ObsidianTest do
  use ExUnit.Case, async: true

  describe "markdown_to_html/1 link support" do
    test "converts external links [text](url) to HTML with new tab and symbol" do
      markdown = "Check out [Google](https://google.com) for search."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">Check out <a href=\"https://google.com\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">Google <span class=\"text-xs\">↗</span></a> for search.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end

    test "converts multiple external links in the same text" do
      markdown = "Visit [Google](https://google.com) or [GitHub](https://github.com) for more info."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">Visit <a href=\"https://google.com\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">Google <span class=\"text-xs\">↗</span></a> or <a href=\"https://github.com\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">GitHub <span class=\"text-xs\">↗</span></a> for more info.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end

    test "converts internal Obsidian links [[note name]] to HTML" do
      markdown = "See also [[Daily Notes]] and [[Project Ideas]]."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">See also <a href=\"obsidian://open?vault=Vault&file=Daily Notes\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" data-obsidian-link=\"Daily Notes\">Daily Notes</a> and <a href=\"obsidian://open?vault=Vault&file=Project Ideas\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" data-obsidian-link=\"Project Ideas\">Project Ideas</a>.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end

    test "handles external and internal links together" do
      markdown = "Check [[My Notes]] or visit [Google](https://google.com)."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">Check <a href=\"obsidian://open?vault=Vault&file=My Notes\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" data-obsidian-link=\"My Notes\">My Notes</a> or visit <a href=\"https://google.com\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">Google <span class=\"text-xs\">↗</span></a>.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end

    test "handles links with special characters" do
      markdown = "Visit [Site with &amp; symbols](https://example.com?q=test&amp;r=1)."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">Visit <a href=\"https://example.com?q=test&amp;r=1\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-blue-400 hover:text-blue-300 underline\">Site with &amp; symbols <span class=\"text-xs\">↗</span></a>.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end

    test "handles Obsidian links with spaces and special characters" do
      markdown = "Reference [[Note with Spaces]] and [[Project-2023]]."
      expected = "<p class=\"text-gray-300 mb-4 leading-relaxed\">Reference <a href=\"obsidian://open?vault=Vault&file=Note with Spaces\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" data-obsidian-link=\"Note with Spaces\">Note with Spaces</a> and <a href=\"obsidian://open?vault=Vault&file=Project-2023\" class=\"text-purple-400 hover:text-purple-300 underline decoration-purple-400/50\" data-obsidian-link=\"Project-2023\">Project-2023</a>.</p>"
      
      result = Mindari.Obsidian.markdown_to_html(markdown)
      assert result == expected
    end
  end
end