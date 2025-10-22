# ReadingTurtle Flutter App - Testing Guide

## 서버 실행 확인

### 1. 백엔드 서버 확인
백엔드 서버가 http://localhost:8010 에서 실행 중인지 확인합니다.

```bash
curl http://localhost:8010/api/auth/login
# 응답: {"success":false,"message":"사용자명과 비밀번호는 필수입니다."}
```

### 2. Flutter 앱 실행
```bash
cd /home/syrikx/booktaco/reading_turtle
flutter run -d web-server --web-port=8080
```

앱이 http://localhost:8080 에서 실행됩니다.

## 테스트 시나리오

### 시나리오 1: 회원가입
1. 브라우저에서 http://localhost:8080 접속
2. "Don't have an account? Sign up" 링크 클릭
3. 다음 정보 입력:
   - Username: `testuser123`
   - Full Name: `Test User`
   - Email: `testuser123@example.com`
   - Password: `password123`
4. "Sign Up" 버튼 클릭
5. **예상 결과**:
   - 회원가입 성공
   - 자동으로 홈 화면으로 이동
   - 상단에 사용자 이름(Test User) 표시
   - "Hello, Test User!" 메시지 표시

### 시나리오 2: 로그아웃
1. 홈 화면 우측 상단의 로그아웃 아이콘 클릭
2. **예상 결과**:
   - 로그아웃 성공
   - 자동으로 로그인 화면으로 이동

### 시나리오 3: 로그인
1. 로그인 화면에서 다음 정보 입력:
   - Username: `testuser123`
   - Password: `password123`
2. "Login" 버튼 클릭
3. **예상 결과**:
   - 로그인 성공
   - 홈 화면으로 이동
   - 사용자 정보 표시

### 시나리오 4: 잘못된 로그인
1. 로그인 화면에서 잘못된 비밀번호 입력:
   - Username: `testuser123`
   - Password: `wrongpassword`
2. "Login" 버튼 클릭
3. **예상 결과**:
   - 에러 메시지 표시 (빨간색 스낵바)
   - "Exception: 사용자명 또는 비밀번호가 일치하지 않습니다."

### 시나리오 5: 중복 회원가입
1. 회원가입 화면에서 이미 존재하는 사용자명/이메일 입력:
   - Username: `testuser123`
   - Full Name: `Another User`
   - Email: `testuser123@example.com`
   - Password: `password456`
2. "Sign Up" 버튼 클릭
3. **예상 결과**:
   - 에러 메시지 표시
   - "Exception: 이미 존재하는 사용자명 또는 이메일입니다."

## 테스트 데이터

### 이미 생성된 테스트 계정
```
Username: flutteruser
Password: password123
Email: flutter@example.com
Full Name: Flutter Test User
```

이 계정으로 즉시 로그인 테스트가 가능합니다.

## API 직접 테스트 (개발자용)

### 회원가입 API
```bash
curl -X POST http://localhost:8010/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username":"apiuser",
    "email":"apiuser@example.com",
    "password":"password123",
    "fullName":"API Test User"
  }'
```

### 로그인 API
```bash
curl -X POST http://localhost:8010/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username":"flutteruser",
    "password":"password123"
  }'
```

## 테스트 시나리오 (도서 검색)

### 시나리오 6: 도서 검색
1. 홈 화면에서 "Search Books" 버튼 클릭
2. 검색 화면에서 "harry" 입력
3. "Search" 버튼 클릭
4. **예상 결과**:
   - 검색 결과가 그리드 형태로 표시됨
   - 각 책에 제목, 저자, BT Level, Lexile 표시
   - 책 표지 이미지 표시
   - 100개의 결과가 표시됨

### 시나리오 7: BT Level 필터
1. 검색 화면에서 검색어 입력: "magic"
2. BT Min: 2.0 입력
3. BT Max: 4.0 입력
4. "Search" 버튼 클릭
5. **예상 결과**:
   - BT Level 2.0~4.0 범위의 책만 표시됨

### 시나리오 8: 검색 결과 없음
1. 검색 화면에서 존재하지 않는 검색어 입력: "xyzabc123notexist"
2. "Search" 버튼 클릭
3. **예상 결과**:
   - "No books found" 메시지 표시

## 현재 구현된 기능

### ✅ 완료
- [x] 회원가입 (Username, Email, Password, Full Name)
- [x] 로그인 (Username, Password)
- [x] 로그아웃
- [x] JWT 토큰 저장 및 관리
- [x] 자동 로그인 (토큰 기반)
- [x] 인증 가드 (로그인하지 않으면 로그인 페이지로 리다이렉트)
- [x] 에러 처리 및 사용자 피드백
- [x] 도서 검색 기능
  - [x] 제목/저자/ISBN/시리즈로 검색
  - [x] BT Level 필터
  - [x] 그리드 레이아웃
  - [x] 도서 카드 (썸네일, 제목, 저자, 레벨)
  - [x] 책 표지 이미지 표시 (캐시 지원)

### 🚧 개발 예정
- [ ] 도서 상세 페이지
- [ ] 단어 공부 기능
- [ ] 단어 퀴즈 기능
- [ ] 마이페이지 및 독서 기록

## 주의사항

1. **CORS 설정**: 백엔드 서버는 CORS를 허용하도록 설정되어 있습니다.
2. **JWT 토큰**: 토큰은 LocalStorage에 저장됩니다 (SharedPreferences).
3. **API 엔드포인트**:
   - 개발: `http://localhost:8010`
   - 프로덕션: `https://reading-turtle.com` (환경변수 설정 필요)

## 문제 해결

### 앱이 로드되지 않는 경우
```bash
# Flutter 앱 재시작
flutter clean
flutter pub get
flutter run -d web-server --web-port=8080
```

### API 연결 오류
1. 백엔드 서버가 실행 중인지 확인
2. `lib/core/config/api_config.dart`에서 baseUrl 확인
3. 브라우저 콘솔에서 네트워크 탭 확인

### 빌드 오류
```bash
# 코드 재생성
flutter pub run build_runner build --delete-conflicting-outputs
```
