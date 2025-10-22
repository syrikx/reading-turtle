-- Insert sample reading sessions for testing
-- Using existing users and books in the database

-- First, get a sample user_id and some book ISBNs
-- Assuming user_id = 1 exists and some books exist

-- Insert reading sessions for the current month (October 2025)
INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-15', 50, 60, 'Started reading this book'
FROM books LIMIT 1
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-16', 45, 55, 'Chapter 2 completed'
FROM books LIMIT 1 OFFSET 1
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-17', 60, 70, 'Making good progress'
FROM books LIMIT 1 OFFSET 2
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-18', 40, 50, 'Interesting story'
FROM books LIMIT 1
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-19', 55, 65, 'Almost halfway'
FROM books LIMIT 1 OFFSET 1
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-20', 50, 60, 'Great characters'
FROM books LIMIT 1 OFFSET 2
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

INSERT INTO reading_sessions (user_id, isbn, session_date, pages_read, reading_minutes, notes)
SELECT 2, isbn, '2025-10-21', 70, 80, 'Today''s reading session'
FROM books LIMIT 1
ON CONFLICT (user_id, isbn, session_date) DO NOTHING;

-- Show inserted sessions
SELECT rs.*, b.title
FROM reading_sessions rs
JOIN books b ON rs.isbn = b.isbn
WHERE rs.user_id = 2
ORDER BY rs.session_date DESC;
