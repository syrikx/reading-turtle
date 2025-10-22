-- Quiz wrong answers table
CREATE TABLE IF NOT EXISTS quiz_wrong_answers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    word_id INTEGER NOT NULL,
    word VARCHAR(100) NOT NULL,
    quiz_type VARCHAR(50), -- 'level', 'known', 'bookmarked', 'studied'
    quiz_filter_value VARCHAR(50), -- e.g., '1.0-2.0' for level, or filter type
    wrong_count INTEGER DEFAULT 1,
    last_wrong_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, word_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_quiz_wrong_answers_user ON quiz_wrong_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_wrong_answers_word ON quiz_wrong_answers(word_id);
CREATE INDEX IF NOT EXISTS idx_quiz_wrong_answers_type ON quiz_wrong_answers(quiz_type);

-- Trigger to update last_wrong_at
CREATE OR REPLACE FUNCTION update_quiz_wrong_answers_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_wrong_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_quiz_wrong_answers_timestamp
    BEFORE UPDATE ON quiz_wrong_answers
    FOR EACH ROW
    EXECUTE FUNCTION update_quiz_wrong_answers_timestamp();
