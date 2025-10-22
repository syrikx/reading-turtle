-- User Word Progress Table
-- Tracks individual user's progress on words (known status, bookmarks, study count)

CREATE TABLE IF NOT EXISTS user_word_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  word_id INTEGER NOT NULL,
  is_known BOOLEAN DEFAULT FALSE,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  last_studied_at TIMESTAMP,
  study_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, word_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_word_progress_user ON user_word_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_word_progress_word ON user_word_progress(word_id);
CREATE INDEX IF NOT EXISTS idx_user_word_progress_known ON user_word_progress(user_id, is_known);
CREATE INDEX IF NOT EXISTS idx_user_word_progress_bookmarked ON user_word_progress(user_id, is_bookmarked);

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_user_word_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_word_progress_timestamp
BEFORE UPDATE ON user_word_progress
FOR EACH ROW
EXECUTE FUNCTION update_user_word_progress_timestamp();

-- Grant permissions (adjust user name as needed)
GRANT SELECT, INSERT, UPDATE, DELETE ON user_word_progress TO turtle_user;
GRANT USAGE, SELECT ON SEQUENCE user_word_progress_id_seq TO turtle_user;
