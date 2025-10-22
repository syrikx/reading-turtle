# ReadingTurtle Flutter Migration TODO

## 프로젝트 개요
기존 HTML/JS 기반 ReadingTurtle을 Flutter로 마이그레이션하여 Android/iOS/Web 지원

## 마이그레이션 원칙
- ✅ TDD (Test-Driven Development) 적용
- ✅ 상태 관리: Riverpod 사용
- ✅ 클린 아키텍처 (Presentation - Domain - Data)
- ✅ API 레이어 분리
- ✅ 각 기능별 단위 테스트 작성

---

## Phase 1: 프로젝트 초기 설정
- [ ] Flutter 프로젝트 생성 (`flutter create reading_turtle`)
- [ ] 필요한 패키지 추가 (pubspec.yaml)
  - [ ] `flutter_riverpod` - 상태 관리
  - [ ] `http` 또는 `dio` - HTTP 클라이언트
  - [ ] `shared_preferences` - 로컬 저장소 (JWT 토큰)
  - [ ] `go_router` - 라우팅
  - [ ] `flutter_test` - 테스트
  - [ ] `mockito` - 목 객체
  - [ ] `freezed` - 불변 모델
  - [ ] `json_annotation` - JSON 직렬화
- [ ] 프로젝트 폴더 구조 생성
  ```
  lib/
  ├── core/           # 공통 유틸리티, 상수
  ├── data/           # API, 모델, 리포지토리 구현
  ├── domain/         # 엔티티, 리포지토리 인터페이스
  ├── presentation/   # UI, 위젯, 상태
  └── main.dart
  ```

---

## Phase 2: Core & Infrastructure
- [ ] API 설정
  - [ ] API 기본 URL 설정 (`http://localhost:8010` 또는 `https://reading-turtle.com`)
  - [ ] API 클라이언트 클래스 작성
  - [ ] JWT 토큰 인터셉터 구현
  - [ ] 에러 핸들링 클래스
- [ ] 로컬 스토리지
  - [ ] JWT 토큰 저장/로드 서비스
  - [ ] 사용자 정보 캐싱
- [ ] 라우터 설정
  - [ ] 라우트 정의 (`/`, `/auth`, `/search`, `/word-study`, `/quiz`, `/mypage`)
  - [ ] 인증 가드 (로그인 필요한 페이지)

---

## Phase 3: 인증 기능 (TDD)
### 3.1 테스트 작성
- [ ] 유닛 테스트: `auth_repository_test.dart`
  - [ ] 로그인 성공 테스트
  - [ ] 로그인 실패 테스트 (잘못된 비밀번호)
  - [ ] 회원가입 성공 테스트
  - [ ] 회원가입 실패 테스트 (중복 아이디)
  - [ ] 토큰 저장/로드 테스트

### 3.2 도메인 레이어
- [ ] `User` 엔티티 (`domain/entities/user.dart`)
- [ ] `AuthRepository` 인터페이스 (`domain/repositories/auth_repository.dart`)

### 3.3 데이터 레이어
- [ ] `UserModel` (`data/models/user_model.dart`)
- [ ] `AuthApiService` (`data/api/auth_api_service.dart`)
- [ ] `AuthRepositoryImpl` (`data/repositories/auth_repository_impl.dart`)

### 3.4 프레젠테이션 레이어
- [ ] `AuthState` (Riverpod StateNotifier)
- [ ] `LoginScreen` UI
  - [ ] 이메일/비밀번호 입력 필드
  - [ ] 로그인 버튼
  - [ ] 회원가입 링크
- [ ] `SignUpScreen` UI
  - [ ] 이메일/비밀번호/이름 입력 필드
  - [ ] 회원가입 버튼
  - [ ] 로그인 링크

### 3.5 위젯 테스트
- [ ] `login_screen_test.dart` - 로그인 화면 렌더링 테스트
- [ ] `signup_screen_test.dart` - 회원가입 화면 테스트

---

## Phase 4: 메인 화면 & 도서 검색
### 4.1 테스트 작성
- [ ] `book_repository_test.dart`
  - [ ] 도서 검색 테스트 (제목, 저자, ISBN)
  - [ ] BT Level / Lexile 필터 테스트
  - [ ] 도서 상세 정보 로드 테스트

### 4.2 도메인 레이어
- [ ] `Book` 엔티티
- [ ] `BookRepository` 인터페이스

### 4.3 데이터 레이어
- [ ] `BookModel`
- [ ] `BookApiService`
- [ ] `BookRepositoryImpl`

### 4.4 프레젠테이션 레이어
- [ ] `HomeScreen` UI
  - [ ] 🐢 ReadingTurtle 헤더
  - [ ] 검색 바
  - [ ] 로그인/로그아웃 버튼
- [ ] `SearchScreen` UI
  - [ ] 검색 결과 그리드
  - [ ] BT Level / Lexile 슬라이더
  - [ ] 도서 카드 (썸네일, 제목, 저자)
- [ ] `BookDetailScreen` UI
  - [ ] 도서 상세 정보
  - [ ] 단어 보기 버튼
  - [ ] 독서 상태 추가 버튼

---

## Phase 5: 단어 공부 기능
### 5.1 테스트 작성
- [ ] `word_repository_test.dart`
  - [ ] BT Level 별 단어 로드 테스트
  - [ ] 완료 상태 토글 테스트
  - [ ] 완료/미완료 필터 테스트

### 5.2 도메인 레이어
- [ ] `Word` 엔티티
- [ ] `WordRepository` 인터페이스

### 5.3 데이터 레이어
- [ ] `WordModel`
- [ ] `WordApiService`
- [ ] `WordRepositoryImpl`

### 5.4 프레젠테이션 레이어
- [ ] `WordStudyScreen` UI
  - [ ] BT Level / Lexile 슬라이더 (단일 값)
  - [ ] 완료 상태 필터 (전체/미완료/완료)
  - [ ] 단어 카드 리스트
    - [ ] 단어
    - [ ] 뜻
    - [ ] 예문
    - [ ] 완료 체크박스
  - [ ] 무한 스크롤 (페이지네이션)
  - [ ] 단어 시험 보기 버튼

---

## Phase 6: 단어 퀴즈 기능
### 6.1 테스트 작성
- [ ] `quiz_repository_test.dart`
  - [ ] 퀴즈 생성 테스트 (5개 보기)
  - [ ] 정답 체크 테스트
  - [ ] 예문에서 답 단어 숨김 테스트

### 6.2 도메인 레이어
- [ ] `Quiz` 엔티티
- [ ] `QuizRepository` 인터페이스

### 6.3 데이터 레이어
- [ ] `QuizModel`
- [ ] `QuizApiService`
- [ ] `QuizRepositoryImpl`

### 6.4 프레젠테이션 레이어
- [ ] `WordQuizScreen` UI
  - [ ] 문제 번호 표시 (#1/10)
  - [ ] 뜻 표시
  - [ ] 예문 표시 (답 단어는 ___ 로 숨김)
  - [ ] 5개 보기 버튼
  - [ ] 다음 문제 버튼
  - [ ] 결과 화면

---

## Phase 7: 마이페이지 & 독서 기록
### 7.1 테스트 작성
- [ ] `reading_history_repository_test.dart`
  - [ ] 독서 기록 로드 테스트
  - [ ] 독서 상태 추가/변경 테스트

### 7.2 도메인 레이어
- [ ] `ReadingHistory` 엔티티
- [ ] `ReadingHistoryRepository` 인터페이스

### 7.3 데이터 레이어
- [ ] `ReadingHistoryModel`
- [ ] `ReadingHistoryApiService`
- [ ] `ReadingHistoryRepositoryImpl`

### 7.4 프레젠테이션 레이어
- [ ] `MyPageScreen` UI
  - [ ] 사용자 정보
  - [ ] 단어 공부하기 버튼
  - [ ] 독서 기록 그리드
  - [ ] 읽고 있는 책 / 읽고 싶은 책 / 읽은 책 탭

---

## Phase 8: 통합 테스트 & 최적화
- [ ] 통합 테스트 작성
  - [ ] 로그인 → 검색 → 도서 상세 → 단어 공부 플로우
  - [ ] 단어 공부 → 퀴즈 플로우
- [ ] 성능 최적화
  - [ ] 이미지 캐싱
  - [ ] API 응답 캐싱
  - [ ] 무한 스크롤 최적화
- [ ] UI/UX 개선
  - [ ] 로딩 인디케이터
  - [ ] 에러 메시지 표시
  - [ ] 스낵바/토스트
- [ ] 다크모드 지원 (선택사항)

---

## Phase 9: 빌드 & 배포
- [ ] Android 빌드 설정
  - [ ] 앱 아이콘
  - [ ] 스플래시 스크린
  - [ ] 권한 설정
- [ ] iOS 빌드 설정
  - [ ] 앱 아이콘
  - [ ] Info.plist 설정
- [ ] Web 빌드 설정
  - [ ] base href 설정
  - [ ] 파비콘
- [ ] 테스트 배포
  - [ ] Android APK/AAB
  - [ ] iOS TestFlight
  - [ ] Web 호스팅

---

## 현재 진행 상황
✅ **Completed**: Phase 1 - 프로젝트 초기 설정
✅ **Completed**: Phase 2 - Core & Infrastructure
✅ **Completed**: Phase 3 - 인증 기능 (TDD)
🔄 **In Progress**: Phase 4 - 메인 화면 & 도서 검색

### 완료된 작업 (2025-10-18)

#### Phase 1-2: 프로젝트 초기 설정
- ✅ Flutter 프로젝트 생성 완료
- ✅ 필요한 패키지 추가 (Riverpod, Dio, GoRouter, Freezed 등)
- ✅ 클린 아키텍처 폴더 구조 생성 (core, data, domain, presentation)
- ✅ API 클라이언트 및 로컬 스토리지 서비스 구현
- ✅ 라우터 설정 (GoRouter + 인증 가드)

#### Phase 3: 인증 기능 (TDD 완료)
- ✅ 인증 도메인 레이어
  - User 엔티티 (id, username, email, fullName)
  - AuthRepository 인터페이스
- ✅ 인증 데이터 레이어
  - UserModel (Freezed + JSON Serialization)
  - AuthApiService (백엔드 API 연동)
  - AuthRepositoryImpl (Repository 구현)
- ✅ 인증 프레젠테이션 레이어
  - AuthState (Freezed로 상태 관리)
  - AuthNotifier (Riverpod StateNotifier)
  - LoginScreen (Username + Password)
  - SignUpScreen (Username + Email + Password + Full Name)
  - HomeScreen (사용자 정보 표시 + 로그아웃)
- ✅ 단위 테스트 작성 (AuthRepository)
- ✅ Freezed/JSON Serialization 코드 생성

#### Phase 3.5: 백엔드 API 연동 및 테스트
- ✅ 백엔드 API 스펙 확인 (`/api/auth/register`, `/api/auth/login`)
- ✅ Flutter API 코드 백엔드에 맞게 수정
  - 필드명 변경 (email → username, name → fullName)
  - 응답 구조 변경 (success, message, user, token)
- ✅ API 테스트 성공
  - 회원가입 API 테스트 완료
  - 로그인 API 테스트 완료
- ✅ 앱 실행 확인 (http://localhost:8080)
- ✅ 테스트 가이드 문서 작성 (`TESTING_GUIDE.md`)

### 테스트 계정
```
Username: flutteruser
Password: password123
Email: flutter@example.com
Full Name: Flutter Test User
```

### 앱 접속 정보
- **Flutter App**: http://localhost:8080
- **Backend API**: http://localhost:8010

#### Phase 4: 도서 검색 기능 (완료)
- ✅ 백엔드 API 분석 (`/api/books/search`)
- ✅ Book 도메인 레이어
  - Book 엔티티 (isbn, title, author, btLevel, lexile 등)
- ✅ Book 데이터 레이어
  - BookModel (Freezed + JSON Serialization)
  - BookApiService (검색 API 연동)
- ✅ Book 프레젠테이션 레이어
  - BookSearchState (검색 상태 관리)
  - BookSearchNotifier (Riverpod StateNotifier)
  - SearchScreen (검색 UI)
  - BookCard (도서 카드 위젯)
- ✅ 검색 화면 라우팅 추가
- ✅ 홈 화면에 검색 버튼 추가
- ✅ 앱 실행 및 테스트

### 다음 단계
1. ✅ ~~백엔드 API 서버 연결 확인~~ (완료)
2. ✅ ~~로그인/회원가입 기능 실제 테스트~~ (완료)
3. ✅ ~~도서 검색 기능 구현~~ (완료)
4. 단어 공부 기능 구현 (Phase 5)

---

## 참고사항
- 기존 백엔드 API: `http://localhost:8010` (개발), `https://reading-turtle.com` (프로덕션)
- 주요 API 엔드포인트:
  - `/api/auth/login` - 로그인
  - `/api/auth/signup` - 회원가입
  - `/api/books/search` - 도서 검색
  - `/api/words/study` - 단어 공부
  - `/api/words/study/toggle` - 완료 상태 토글
  - `/api/quiz/generate` - 퀴즈 생성
  - `/api/reading-history` - 독서 기록

---

## 체크리스트 범례
- [ ] 미완료
- [x] 완료
- 🔄 진행 중
