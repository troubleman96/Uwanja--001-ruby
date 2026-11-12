module RAR
  class Memory
    def initialize(path = "data/agent_memory.sqlite3")
      FileUtils.mkdir_p(File.dirname(path))
      require "sqlite3"
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true
      @db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      SQL
    end

    def save(content)
      @db.execute("INSERT INTO notes(content, created_at) VALUES(?, ?)",
                  [content, Time.now.utc.iso8601])
      @db.last_insert_row_id
    end

    def search(query = "", limit: 10)
      if query.to_s.strip.empty?
        @db.execute("SELECT * FROM notes ORDER BY id DESC LIMIT ?", limit)
      else
        @db.execute("SELECT * FROM notes WHERE content LIKE ? ORDER BY id DESC LIMIT ?",
                    ["%#{query}%", limit])
      end
    end
  end
end
