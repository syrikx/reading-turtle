-- Quiz 테이블 생성 스크립트

-- 1. quizzes 테이블: Quiz 메타데이터
CREATE TABLE IF NOT EXISTS quizzes (
    quiz_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL,
    title TEXT,
    total_questions INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_quiz_isbn FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE,
    CONSTRAINT unique_quiz_isbn UNIQUE(isbn)
);

-- 2. quiz_questions 테이블: 각 문제
CREATE TABLE IF NOT EXISTS quiz_questions (
    question_id SERIAL PRIMARY KEY,
    quiz_id INTEGER NOT NULL,
    question_number INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    choice_1 TEXT NOT NULL,
    choice_2 TEXT NOT NULL,
    choice_3 TEXT NOT NULL,
    choice_4 TEXT NOT NULL,
    correct_answer TEXT NOT NULL,
    correct_choice_number INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_question_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
    CONSTRAINT unique_quiz_question UNIQUE(quiz_id, question_number),
    CONSTRAINT check_choice_number CHECK (correct_choice_number >= 1 AND correct_choice_number <= 4)
);

-- 3. 정답 번호 자동 계산 함수
CREATE OR REPLACE FUNCTION calculate_correct_choice_number()
RETURNS TRIGGER AS $$
BEGIN
    -- correct_answer와 일치하는 choice 찾기
    IF NEW.correct_answer = NEW.choice_1 THEN
        NEW.correct_choice_number := 1;
    ELSIF NEW.correct_answer = NEW.choice_2 THEN
        NEW.correct_choice_number := 2;
    ELSIF NEW.correct_answer = NEW.choice_3 THEN
        NEW.correct_choice_number := 3;
    ELSIF NEW.correct_answer = NEW.choice_4 THEN
        NEW.correct_choice_number := 4;
    ELSE
        -- 정답이 보기와 일치하지 않는 경우 경고
        RAISE NOTICE 'Warning: correct_answer does not match any choice for question_id %', NEW.question_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. 트리거 생성
DROP TRIGGER IF EXISTS set_correct_choice_number ON quiz_questions;
CREATE TRIGGER set_correct_choice_number
    BEFORE INSERT OR UPDATE ON quiz_questions
    FOR EACH ROW
    EXECUTE FUNCTION calculate_correct_choice_number();

-- 5. 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_quizzes_isbn ON quizzes(isbn);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_question_number ON quiz_questions(question_number);

-- 6. 코멘트 추가
COMMENT ON TABLE quizzes IS 'Quiz 메타데이터 테이블';
COMMENT ON TABLE quiz_questions IS 'Quiz 문제 상세 정보 테이블';
COMMENT ON COLUMN quizzes.isbn IS '책의 ISBN (books 테이블 참조)';
COMMENT ON COLUMN quiz_questions.question_number IS '문제 번호 (1부터 시작)';
COMMENT ON COLUMN quiz_questions.correct_choice_number IS '정답 번호 (1-4, 트리거로 자동 계산)';
