module RAR
  module Tools
    def self.build(memory)
      registry = ToolRegistry.new

      registry.register(Tool.new(
        name: "calculator",
        description: "Evaluate a basic arithmetic expression. Argument: expression (string)."
      ) do |args|
        expression = args.fetch("expression").to_s
        # Deliberately allow only digits, spaces, decimal points and arithmetic operators.
        raise ArgumentError, "Only basic arithmetic is allowed" unless expression.match?(/\A[0-9+\-*\/.() %]+\z/)
        raise ArgumentError, "Expression too long" if expression.length > 100
        result = eval(expression, binding, "(calculator)", 1) # rubocop:disable Security/Eval
        { result: result }
      end)

      registry.register(Tool.new(
        name: "save_note",
        description: "Save a note to the agent's persistent memory. Argument: content (string)."
      ) do |args|
        content = args.fetch("content").to_s.strip
        raise ArgumentError, "Note cannot be empty" if content.empty?
        { saved_note_id: memory.save(content), content: content }
      end)

      registry.register(Tool.new(
        name: "search_notes",
        description: "Search saved notes. Argument: query (string)."
      ) do |args|
        rows = memory.search(args.fetch("query", ""))
        { notes: rows.map { |r| { id: r["id"], content: r["content"] } } }
      end)

      registry.register(Tool.new(
        name: "delete_all_notes",
        description: "Delete all saved notes. This is a destructive operation.",
        risk: :high
      ) do |_args|
        # The demo intentionally does not expose an actual destructive implementation.
        { message: "Demo safety: deletion tool is registered but execution is disabled." }
      end)

      registry
    end
  end
end
