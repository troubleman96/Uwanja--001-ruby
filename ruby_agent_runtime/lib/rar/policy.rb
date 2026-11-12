module RAR
  class Policy
    def requires_approval?(tool)
      tool.risk == :high
    end
  end
end
