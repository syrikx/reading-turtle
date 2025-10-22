-- Alter word_study_progress table to support new features
-- Add columns for word_id, is_known, is_bookmarked, study_count, last_studied_at

-- Add word_id column (nullable for now, we'll populate it later)
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS word_id INTEGER;

-- Add is_known column (rename completed to is_known conceptually, but keep both for compatibility)
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS is_known BOOLEAN DEFAULT FALSE;

-- Add is_bookmarked column
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS is_bookmarked BOOLEAN DEFAULT FALSE;

-- Add study_count column
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS study_count INTEGER DEFAULT 0;

-- Add last_studied_at column (migrate from completed_at)
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS last_studied_at TIMESTAMP;

-- Migrate existing data: completed -> is_known, completed_at -> last_studied_at
UPDATE word_study_progress
SET is_known = completed,
    last_studied_at = COALESCE(last_studied_at, completed_at)
WHERE is_known IS NULL OR last_studied_at IS NULL;

-- Add index for new columns
CREATE INDEX IF NOT EXISTS idx_word_study_progress_word_id ON word_study_progress(word_id);
CREATE INDEX IF NOT EXISTS idx_word_study_progress_bookmarked ON word_study_progress(user_id, is_bookmarked);

-- Add updated_at column if not exists
ALTER TABLE word_study_progress
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_word_study_progress_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_word_study_progress_timestamp ON word_study_progress;
CREATE TRIGGER trigger_update_word_study_progress_timestamp
BEFORE UPDATE ON word_study_progress
FOR EACH ROW
EXECUTE FUNCTION update_word_study_progress_timestamp();
