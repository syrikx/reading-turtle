# 🐢 ReadingTurtle

독서 습관 관리 및 독서 기록 시스템

## 기능

### 📚 도서 관리
- 121,000+ 권의 도서 데이터베이스
- BookTaco API 기반 도서 정보 크롤링
- BT Level, Lexile 지수 기반 필터링
- 장르, 시리즈별 검색

### 🎯 퀴즈 시스템
- 도서별 독해 퀴즈 제공
- 객관식 문제 형식
- 즉시 채점 및 피드백

### 📖 단어 학습
- 도서별 어휘 목록 제공
- 단어 정의 및 예문
- 87,000+ 단어 데이터

### 👤 사용자 관리
- 회원가입 및 로그인
- JWT 기반 인증
- 개인별 독서 기록 관리

## 기술 스택

### Backend
- **Node.js** + **Express.js** - REST API 서버
- **PostgreSQL** - 데이터베이스
- **JWT** - 인증
- **bcryptjs** - 비밀번호 암호화

### Frontend
- **Vanilla JavaScript** - 프론트엔드 로직
- **HTML5 / CSS3** - UI/UX
- **Fetch API** - 비동기 통신

### Data Crawling
- **Python 3** - 데이터 크롤링
- **asyncio / aiohttp** - 비동기 HTTP 요청
- **psycopg2** - PostgreSQL 연결

## 설치 및 실행

### 1. 의존성 설치
```bash
npm install
```

### 2. 데이터베이스 설정
```bash
# PostgreSQL 설치 후
psql -U postgres
CREATE DATABASE booktaco;
CREATE USER booktaco_user WITH PASSWORD 'ares82';
GRANT ALL PRIVILEGES ON DATABASE booktaco TO booktaco_user;

# 스키마 생성
psql -U booktaco_user -d booktaco -f schema.sql
psql -U booktaco_user -d booktaco -f schema_quiz.sql
psql -U booktaco_user -d booktaco -f schema_words.sql
psql -U booktaco_user -d booktaco -f schema_users.sql
```

### 3. 데이터 임포트
```bash
# 도서 데이터 임포트
python3 import_to_postgres.py

# 퀴즈 데이터 크롤링
python3 save_quizzes_to_db.py

# 단어 데이터 크롤링 (선택)
python3 save_words_to_db_async.py
```

### 4. 서버 실행
```bash
npm start
# 또는 개발 모드
npm run dev
```

서버가 http://localhost:8010 에서 실행됩니다.

## API 엔드포인트

### 도서 조회
- `GET /api/books/browse` - 도서 목록 (필터링)
- `GET /api/books/search/title` - 제목 검색
- `GET /api/books/search/author` - 저자 검색
- `GET /api/books/search/series` - 시리즈 검색
- `GET /api/books/search/isbn` - ISBN 검색

### 퀴즈
- `GET /api/books/:isbn/quizzes` - 도서별 퀴즈 목록
- `GET /api/quizzes/:quizId` - 퀴즈 상세 정보

### 단어
- `GET /api/books/:isbn/words` - 도서별 단어 목록

### 인증
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인
- `GET /api/auth/me` - 현재 사용자 정보
- `POST /api/auth/logout` - 로그아웃

## 데이터베이스 스키마

### books
도서 기본 정보 (ISBN, 제목, 저자, BT Level, Lexile 등)

### quizzes
퀴즈 문제 및 정답

### word_definitions
단어 정의 (중복 제거)

### word_lists
도서별 단어 목록

### users
사용자 정보

## 라이선스

MIT
