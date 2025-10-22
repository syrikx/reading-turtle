# 고객센터 게시판 (Customer Support Board)

## 개요
로그인한 사용자가 개발자와 소통할 수 있는 고객센터 게시판 기능입니다.

## 기능

### 사용자 기능
1. **문의 작성**: 제목과 내용을 입력하여 새로운 문의를 작성할 수 있습니다
2. **문의 목록**: 자신이 작성한 모든 문의를 확인할 수 있습니다
3. **문의 상세**: 문의 내용과 답변을 확인할 수 있습니다
4. **문의 수정**: 자신이 작성한 문의를 수정할 수 있습니다
5. **문의 삭제**: 자신이 작성한 문의를 삭제할 수 있습니다
6. **댓글 작성**: 문의에 댓글을 추가할 수 있습니다

### 상태 관리
- **open**: 답변 대기 중
- **answered**: 답변 완료
- **closed**: 종료됨

## 데이터베이스 구조

### support_posts 테이블
```sql
- post_id: SERIAL PRIMARY KEY
- user_id: INTEGER (users 테이블 참조)
- title: VARCHAR(200)
- content: TEXT
- status: VARCHAR(20) (open/answered/closed)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

### support_replies 테이블
```sql
- reply_id: SERIAL PRIMARY KEY
- post_id: INTEGER (support_posts 테이블 참조)
- user_id: INTEGER (users 테이블 참조)
- content: TEXT
- is_admin: BOOLEAN (관리자/개발자 답변 여부)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

## API 엔드포인트

### 게시글 관련
- `GET /api/support/posts` - 문의 목록 조회
- `GET /api/support/posts/:postId` - 문의 상세 조회 (댓글 포함)
- `POST /api/support/posts` - 새 문의 작성
- `PUT /api/support/posts/:postId` - 문의 수정
- `DELETE /api/support/posts/:postId` - 문의 삭제

### 댓글 관련
- `POST /api/support/posts/:postId/replies` - 댓글 작성

## Flutter 구조

### Entities
- `SupportPost` - 문의 게시글 엔티티
- `SupportReply` - 댓글 엔티티

### Models
- `SupportPostModel` - 문의 게시글 모델
- `SupportReplyModel` - 댓글 모델

### API Service
- `SupportApiService` - 고객센터 API 서비스

### Providers
- `supportProvider` - 문의 목록 상태 관리
- `supportDetailProvider` - 문의 상세 상태 관리 (postId별로 관리)

### Screens
- `SupportListScreen` - 문의 목록 화면 (`/support`)
- `SupportDetailScreen` - 문의 상세 화면 (`/support/:postId`)
- `SupportFormScreen` - 문의 작성/수정 화면 (`/support/new`, `/support/:postId/edit`)

## 접근 방법
1. 로그인 후 상단 프로필 아이콘 클릭
2. 드롭다운 메뉴에서 "고객센터" 선택
3. 우측 하단 "문의하기" 버튼으로 새 문의 작성

## 향후 개선 사항
- [ ] 관리자 권한 추가 (모든 문의 확인 가능)
- [ ] 이메일 알림 (새 답변 시)
- [ ] 문의 카테고리 추가
- [ ] 파일 첨부 기능
- [ ] 검색 기능
