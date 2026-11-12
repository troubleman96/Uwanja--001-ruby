module RAR
  # A model adapter returns either { "type"=>"final", "text"=>"..." }
  # or { "type"=>"tool_call", "name"=>"...", "arguments"=>{...} }.
  # Replace this demo adapter with an LLM API adapter later.
  class DemoModel
    def respond(user_message:, tool_results: [])
      text = user_message.to_s

      if text.match?(/\d+\s*[+\-*\/]\s*\d+/)
        expression = text[/[0-9+\-*\/.() %]+/]
        return { "type" => "tool_call", "name" => "calculator",
                 "arguments" => { "expression" => expression } }
      elsif text.match?(/remember|save.*note/i)
        content = text.sub(/\A.*?(remember|save.*?note)\s*/i, "").strip
        content = text if content.empty?
        return { "type" => "tool_call", "name" => "save_note",
                 "arguments" => { "content" => content } }
      elsif text.match?(/search.*notes|find.*note/i)
        query = text.sub(/\A.*?(notes?|for)\s*/i, "").strip
        return { "type" => "tool_call", "name" => "search_notes",
                 "arguments" => { "query" => query } }
      elsif text.match?(/delete.*notes/i)
        return { "type" => "tool_call", "name" => "delete_all_notes",
                 "arguments" => {} }
      end

      if tool_results.any?
        last = tool_results.last
        return { "type" => "final", "text" => "I used #{last[:tool]} and got: #{last[:result].inspect}" }
      end

      { "type" => "final",
        "text" => "I am the demo agent. Try: 'What is 12 * 8?', 'Remember that I am learning Ruby', or 'Search notes for Ruby'." }
    end
  end
end
