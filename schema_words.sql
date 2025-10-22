-- 단어 정의 테이블 (단어별 고유 정보)
CREATE TABLE IF NOT EXISTS word_definitions (
    word_id INTEGER PRIMARY KEY,  -- API의 WordID 사용
    word VARCHAR(100) UNIQUE NOT NULL,
    definition TEXT NOT NULL,
    example_sentence TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 책별 단어 목록 테이블
CREATE TABLE IF NOT EXISTS word_lists (
    wordlist_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL REFERENCES books(isbn) ON DELETE CASCADE,
    word VARCHAR(100) NOT NULL,
    word_order INTEGER NOT NULL,  -- 단어 순서 (리스트에서의 위치)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(isbn, word)  -- 같은 책에 같은 단어 중복 방지
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_word_lists_isbn ON word_lists(isbn);
CREATE INDEX IF NOT EXISTS idx_word_lists_word ON word_lists(word);
CREATE INDEX IF NOT EXISTS idx_word_definitions_word ON word_definitions(word);

-- 업데이트 시간 자동 갱신을 위한 트리거
CREATE OR REPLACE FUNCTION update_word_definitions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_word_definitions_updated_at ON word_definitions;
CREATE TRIGGER update_word_definitions_updated_at
    BEFORE UPDATE ON word_definitions
    FOR EACH ROW
    EXECUTE FUNCTION update_word_definitions_updated_at();

-- 테이블 코멘트
COMMENT ON TABLE word_definitions IS '단어 정의 테이블 - 중복 방지를 위해 단어별로 한 번만 저장';
COMMENT ON TABLE word_lists IS '책별 단어 목록 - 각 책에 포함된 단어들의 목록';
COMMENT ON COLUMN word_lists.word_order IS '단어의 순서 (API에서 반환된 순서 유지)';
