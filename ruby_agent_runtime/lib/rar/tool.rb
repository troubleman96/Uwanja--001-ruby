module RAR
  class Tool
    attr_reader :name, :description, :risk

    def initialize(name:, description:, risk: :low, &block)
      @name = name
      @description = description
      @risk = risk
      @callable = block
    end

    def call(arguments = {})
      @callable.call(arguments)
    end
  end

  class ToolRegistry
    def initialize
      @tools = {}
    end

    def register(tool)
      raise ArgumentError, "Tool name already registered: #{tool.name}" if @tools.key?(tool.name)
      @tools[tool.name] = tool
    end

    def fetch(name)
      @tools[name] || raise(ArgumentError, "Unknown tool: #{name}")
    end

    def descriptions
      @tools.values.map { |t| { name: t.name, description: t.description, risk: t.risk } }
    end
  end
end
