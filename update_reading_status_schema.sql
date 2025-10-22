-- Update reading_history table to simplify status
-- Only 'reading' and 'completed' are allowed

-- Drop old constraint
ALTER TABLE reading_history DROP CONSTRAINT IF EXISTS reading_history_status_check;

-- Update existing 'started' status to 'reading' BEFORE adding new constraint
UPDATE reading_history SET status = 'reading' WHERE status = 'started';

-- Add new constraint with only 'reading' and 'completed'
ALTER TABLE reading_history ADD CONSTRAINT reading_history_status_check
  CHECK (status IN ('reading', 'completed'));

-- Ensure started_at is set when status is 'reading' and started_at is null
UPDATE reading_history
SET started_at = COALESCE(reading_at, created_at)
WHERE status = 'reading' AND started_at IS NULL;

-- Ensure completed_at is set when status is 'completed' and completed_at is null
UPDATE reading_history
SET completed_at = updated_at
WHERE status = 'completed' AND completed_at IS NULL;

-- Comments for clarity
COMMENT ON COLUMN reading_history.started_at IS 'Date when user first started reading (first time clicking "읽는 중")';
COMMENT ON COLUMN reading_history.completed_at IS 'Date when user completed reading (clicking "완료")';
COMMENT ON COLUMN reading_history.reading_at IS 'Deprecated - kept for backward compatibility';
COMMENT ON COLUMN reading_history.status IS 'reading: currently reading, completed: finished reading';
