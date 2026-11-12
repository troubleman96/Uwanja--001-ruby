module RAR
  class ApprovalStore
    def initialize(path = "data/agent_approvals.sqlite3")
      FileUtils.mkdir_p(File.dirname(path))
      require "sqlite3"
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true
      @db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS approvals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tool_name TEXT NOT NULL,
          arguments_json TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          requested_at TEXT NOT NULL,
          reviewed_by TEXT,
          reviewed_at TEXT,
          review_note TEXT
        )
      SQL
    end

    def request(tool_name, arguments)
      @db.execute(
        "INSERT INTO approvals(tool_name,arguments_json,requested_at) VALUES(?,?,?)",
        [tool_name, JSON.generate(arguments), Time.now.utc.iso8601]
      )
      @db.last_insert_row_id
    end

    def pending
      @db.execute("SELECT * FROM approvals WHERE status='pending' ORDER BY id")
    end

    def find_pending(id)
      @db.get_first_row("SELECT * FROM approvals WHERE id=? AND status='pending'", id.to_i)
    end

    def decide(id, status, reviewer, note = "")
      raise ArgumentError, "Invalid decision" unless %w[approved rejected].include?(status)
      @db.execute(
        "UPDATE approvals SET status=?, reviewed_by=?, reviewed_at=?, review_note=? WHERE id=? AND status='pending'",
        [status, reviewer, Time.now.utc.iso8601, note, id.to_i]
      )
      @db.changes == 1
    end
  end
end
