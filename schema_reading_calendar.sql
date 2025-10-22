-- Reading Calendar Schema
-- Tracks daily reading sessions for calendar visualization

-- Table: reading_sessions
-- Purpose: Store daily reading records with book information
CREATE TABLE IF NOT EXISTS reading_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    session_date DATE NOT NULL,
    pages_read INTEGER DEFAULT 0,
    reading_minutes INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign keys
    CONSTRAINT fk_reading_session_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_reading_session_book FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE,

    -- Prevent duplicate sessions for same user, book, and date
    CONSTRAINT unique_user_book_date UNIQUE (user_id, isbn, session_date)
);

-- Index for faster queries by user and date range
CREATE INDEX idx_reading_sessions_user_date ON reading_sessions(user_id, session_date DESC);
CREATE INDEX idx_reading_sessions_book ON reading_sessions(isbn);

-- Grant permissions to turtle_user
GRANT ALL PRIVILEGES ON TABLE reading_sessions TO turtle_user;
GRANT USAGE, SELECT ON SEQUENCE reading_sessions_session_id_seq TO turtle_user;

-- Example queries:
-- Get all reading sessions for a user in a specific month:
-- SELECT rs.*, b.title, b.img
-- FROM reading_sessions rs
-- JOIN books b ON rs.isbn = b.isbn
-- WHERE rs.user_id = 1
--   AND rs.session_date >= '2025-01-01'
--   AND rs.session_date < '2025-02-01'
-- ORDER BY rs.session_date DESC;

-- Get total pages read per day:
-- SELECT session_date, SUM(pages_read) as total_pages, COUNT(DISTINCT isbn) as books_count
-- FROM reading_sessions
-- WHERE user_id = 1
-- GROUP BY session_date
-- ORDER BY session_date DESC;
