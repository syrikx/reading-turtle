-- 회원 테이블
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- 독서 기록 테이블
CREATE TABLE IF NOT EXISTS reading_history (
    history_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    isbn VARCHAR(20) NOT NULL REFERENCES books(isbn) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('started', 'reading', 'completed')),
    started_at TIMESTAMP,
    reading_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, isbn)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_reading_history_user_id ON reading_history(user_id);
CREATE INDEX IF NOT EXISTS idx_reading_history_isbn ON reading_history(isbn);
CREATE INDEX IF NOT EXISTS idx_reading_history_status ON reading_history(status);
CREATE INDEX IF NOT EXISTS idx_reading_history_user_status ON reading_history(user_id, status);

-- 업데이트 시간 자동 갱신을 위한 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
DROP TRIGGER IF EXISTS update_reading_history_updated_at ON reading_history;
CREATE TRIGGER update_reading_history_updated_at
    BEFORE UPDATE ON reading_history
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 기본 관리자 계정 생성 (비밀번호: admin123)
-- 실제 운영 시에는 반드시 변경하세요!
INSERT INTO users (username, email, password_hash, full_name)
VALUES ('admin', 'admin@booktaco.com', '$2a$10$rQ3qN5yZp8VYKvZ4sZKGLuqJ4fXpYvXJ7KxYxGz0sZXQcKQNyZJlm', 'Administrator')
ON CONFLICT (username) DO NOTHING;

COMMENT ON TABLE users IS '회원 정보 테이블';
COMMENT ON TABLE reading_history IS '독서 기록 히스토리 테이블';
COMMENT ON COLUMN reading_history.status IS 'started: 읽기 시작, reading: 읽는 중, completed: 읽기 완료';
