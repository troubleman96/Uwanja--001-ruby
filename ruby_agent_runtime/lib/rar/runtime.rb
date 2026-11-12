module RAR
  class Runtime
    def initialize(model:, tools:, policy:, approvals:, max_steps: 5)
      @model = model
      @tools = tools
      @policy = policy
      @approvals = approvals
      @max_steps = max_steps
    end

    def run(user_message)
      tool_results = []
      @max_steps.times do
        response = @model.respond(user_message: user_message, tool_results: tool_results)

        case response.fetch("type")
        when "final"
          return { status: "completed", answer: response.fetch("text"), tool_results: tool_results }
        when "tool_call"
          tool = @tools.fetch(response.fetch("name"))
          arguments = response.fetch("arguments", {})

          if @policy.requires_approval?(tool)
            request_id = @approvals.request(tool.name, arguments)
            return {
              status: "needs_approval",
              message: "Human approval is required before this tool can run.",
              approval_id: request_id,
              tool: tool.name
            }
          end

          result = tool.call(arguments)
          tool_results << { tool: tool.name, result: result }
        else
          raise "Model returned an unsupported response type"
        end
      end

      { status: "max_steps_reached", answer: "Stopped to prevent an unbounded agent loop.", tool_results: tool_results }
    rescue StandardError => e
      { status: "error", error: "#{e.class}: #{e.message}", tool_results: tool_results }
    end

    def approve(approval_id, reviewer:, note: "")
      request = @approvals.find_pending(approval_id)
      raise ArgumentError, "No pending approval with that ID" unless request

      tool = @tools.fetch(request["tool_name"])
      arguments = JSON.parse(request["arguments_json"])
      raise "Tool is no longer classified as high risk" unless @policy.requires_approval?(tool)

      # Mark the request approved before execution to prevent repeat approvals.
      # In production, use one transaction covering decision + action + audit.
      changed = @approvals.decide(approval_id, "approved", reviewer, note)
      raise "Approval was already processed" unless changed

      { status: "approved", tool: tool.name,
        result: tool.call(arguments) }
    end

    def reject(approval_id, reviewer:, note: "")
      changed = @approvals.decide(approval_id, "rejected", reviewer, note)
      raise ArgumentError, "No pending approval with that ID" unless changed
      { status: "rejected" }
    end
  end
end
