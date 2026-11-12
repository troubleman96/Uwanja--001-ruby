# Ruby Agent Runtime

A small educational agent runtime in Ruby. It demonstrates the control loop around a model, tool registry, tool execution, persistent notes, a policy gate, and human approval.

## Requirements

- Ruby 3.1+
- Bundler
- SQLite (the sqlite3 gem includes/binds the SQLite library depending on platform)

## Install

```bash
bundle install
```

## Run examples

Calculator tool:

```bash
bundle exec ruby bin/agent run "What is 12 * 8?"
```

Save a note:

```bash
bundle exec ruby bin/agent run "Remember that I am learning Ruby"
```

Search notes:

```bash
bundle exec ruby bin/agent run "Search notes for Ruby"
```

Request a sensitive action:

```bash
bundle exec ruby bin/agent run "Delete all notes"
bundle exec ruby bin/agent pending
```

The delete tool is deliberately a harmless demo stub. The runtime still demonstrates how it places a high-risk tool call in the approval queue. Approve/reject:

```bash
bundle exec ruby bin/agent approve 1 "human-reviewer" "Reviewed"
# or
bundle exec ruby bin/agent reject 1 "human-reviewer" "Not allowed"
```

## Architecture

```text
User
 |
 v
Runtime (bounded agent loop)
 |
 +--> Model adapter (DemoModel; replaceable)
 |
 +--> Tool registry
 |      +--> calculator
 |      +--> save_note
 |      +--> search_notes
 |      +--> delete_all_notes (high risk demo stub)
 |
 +--> Policy gate
 |      +--> low risk: execute
 |      +--> high risk: create approval request
 |
 +--> Memory (SQLite)
 |
 +--> Approval store (SQLite)
```

## What makes this an agent runtime?

An LLM by itself generates text. An agent runtime provides the surrounding execution system:

1. It asks a model what to do.
2. It checks whether the model requested a tool.
3. It validates that the tool exists.
4. It applies policy and approval rules.
5. It executes permitted tools.
6. It returns tool results to the model.
7. It repeats until the model returns a final answer or the step limit is reached.

This demo uses `DemoModel`, a deterministic rule-based adapter, so it runs without an API key. It is an educational runtime, not a production-ready agent. In particular, reviewer names are not authentication, approval execution needs stronger transactional/idempotency guarantees, tool arguments need schema validation, and a real LLM adapter should be added before production use.
