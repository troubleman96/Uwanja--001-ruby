# Agent runtime architecture notes

## Main pieces

- **Model adapter**: decides whether to answer or request a tool. The runtime does not depend on a specific model vendor.
- **Tool registry**: allowlist of capabilities the agent can invoke.
- **Tool**: a named operation with a description, risk level, and Ruby callable.
- **Runtime**: the bounded orchestration loop.
- **Policy**: decides whether a tool call can run automatically or needs approval.
- **Approval store**: persists pending human decisions.
- **Memory**: stores simple durable notes.

## Agent loop

```text
user input
  -> model adapter
  -> final answer? -------- yes -> return
  -> tool call
  -> registry lookup
  -> policy check
  -> approval required? --- yes -> queue and pause
  -> execute tool
  -> append tool result
  -> ask model again
```

The maximum step count is a safety limit against infinite loops.

## Production hardening checklist

- Authenticate users and reviewers; never trust a typed reviewer name.
- Authorize each tool by user, tenant, and role.
- Validate tool arguments against strict JSON schemas.
- Add timeouts, retries, rate limits, and per-run budgets.
- Keep an append-only audit trail.
- Use database transactions and idempotency keys for approval + execution.
- Treat model output, retrieved memory, and tool output as untrusted input.
- Add prompt-injection defenses and restrict tools to least privilege.
- Add tests for policy bypasses, duplicate approvals, malformed arguments, and tool failures.
- Use a real LLM adapter only after defining data retention and privacy rules.
