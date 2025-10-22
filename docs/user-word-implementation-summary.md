# User Word Study Feature Implementation Summary

## Overview
Successfully implemented user-specific word study functionality for the Reading Turtle app, allowing users to track their progress on individual words with known status, bookmarks, and study counts.

## Implementation Date
2025-10-19

## Database Schema

### Table: `word_study_progress`
Located in: `readingturtle` database

**Columns:**
- `id` - SERIAL PRIMARY KEY
- `user_id` - INTEGER NOT NULL (FK to users.user_id)
- `word` - VARCHAR(100) NOT NULL
- `word_id` - INTEGER (reference to word_lists.wordlist_id)
- `is_known` - BOOLEAN DEFAULT FALSE
- `is_bookmarked` - BOOLEAN DEFAULT FALSE
- `study_count` - INTEGER DEFAULT 0
- `last_studied_at` - TIMESTAMP
- `completed` - BOOLEAN DEFAULT TRUE (legacy)
- `completed_at` - TIMESTAMP (legacy)
- `updated_at` - TIMESTAMP DEFAULT CURRENT_TIMESTAMP

**Indexes:**
- PRIMARY KEY on `id`
- UNIQUE CONSTRAINT on `(user_id, word)`
- Index on `user_id`
- Index on `word`
- Index on `word_id`
- Index on `(user_id, is_bookmarked)`
- Index on `(user_id, completed)` (legacy)

**Foreign Keys:**
- `user_id` REFERENCES `users(user_id)` ON DELETE CASCADE

**Triggers:**
- `trigger_update_word_study_progress_timestamp` - Auto-updates `updated_at` on UPDATE

## API Endpoints

All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

### 1. GET /api/user-words/progress/:isbn
Get all word progress data for a specific book.

**Request:**
```
GET /api/user-words/progress/9781338565379
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "word_id": 123,
      "word": "example",
      "is_known": true,
      "is_bookmarked": false,
      "last_studied_at": "2025-01-15T10:30:00Z",
      "study_count": 3
    }
  ]
}
```

### 2. POST /api/user-words/known
Toggle word known status.

**Request:**
```json
POST /api/user-words/known
Authorization: Bearer <token>
Content-Type: application/json

{
  "word_id": 123,
  "is_known": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "단어 상태가 업데이트되었습니다.",
  "data": {
    "word_id": 123,
    "word": "example",
    "is_known": true,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

### 3. POST /api/user-words/bookmark
Toggle word bookmark.

**Request:**
```json
POST /api/user-words/bookmark
Authorization: Bearer <token>
Content-Type: application/json

{
  "word_id": 123,
  "is_bookmarked": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "북마크가 업데이트되었습니다.",
  "data": {
    "word_id": 123,
    "word": "example",
    "is_bookmarked": true,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

### 4. POST /api/user-words/study
Record word study (increment study count).

**Request:**
```json
POST /api/user-words/study
Authorization: Bearer <token>
Content-Type: application/json

{
  "word_id": 123
}
```

**Response:**
```json
{
  "success": true,
  "message": "학습이 기록되었습니다.",
  "data": {
    "word_id": 123,
    "word": "example",
    "study_count": 4,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

### 5. GET /api/user-words/stats
Get overall word study statistics for the current user.

**Request:**
```
GET /api/user-words/stats
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_words": "150",
    "known_words": "45",
    "bookmarked_words": "12",
    "studied_words": "78"
  }
}
```

### 6. GET /api/user-words/bookmarked
Get all bookmarked words for the current user.

**Request:**
```
GET /api/user-words/bookmarked
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "word_id": 123,
      "word": "example",
      "definition": "a thing characteristic of its kind",
      "is_known": false,
      "study_count": 2,
      "last_studied_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

## Flutter Implementation

### State Management
- **Provider**: `UserWordProvider` (Riverpod StateNotifier)
- **State Model**: `UserWordState` (Freezed)
  - States: `initial`, `loading`, `loaded`, `error`
- **Data Models**:
  - `UserWordProgress` - Individual word progress
  - `UserWordStats` - Overall statistics

### API Service
- **File**: `lib/data/api/user_word_api_service.dart`
- **Methods**:
  - `getUserWordProgress(String isbn)`
  - `toggleWordKnown(int wordId, bool isKnown)`
  - `toggleWordBookmark(int wordId, bool isBookmarked)`
  - `recordWordStudy(int wordId)`
  - `getUserWordStats()`
  - `getBookmarkedWords()`

### UI Components

#### WordCardWidget
- **File**: `lib/presentation/widgets/word_card_widget.dart`
- **Features**:
  - Bookmark button (icon changes based on state)
  - "알고있음" toggle button
  - Visual feedback for known words (grey text, strikethrough)
  - Study count display
  - Loading state during API calls

#### Word Study Screen
- **File**: `lib/presentation/screens/word_study/word_study_screen.dart`
- **Features**:
  - Progress bar showing completion percentage
  - Filter chips: 전체 (All), 알고있음 (Known), 모름 (Unknown), 북마크 (Bookmarked)
  - Integration with user word progress
  - Real-time updates after status changes

### Entity Updates
- **Word Entity** (`lib/domain/entities/word.dart`):
  - Added: `isKnown`, `isBookmarked`, `studyCount`
- **WordModel** (`lib/data/models/word_model.dart`):
  - Added JSON serialization for user progress fields

## Testing Results

All 6 API endpoints tested successfully with user_id=4 (flutteruser):

✅ GET /api/user-words/progress/:isbn - Returns word list with progress
✅ POST /api/user-words/known - Updates known status
✅ POST /api/user-words/bookmark - Updates bookmark status
✅ POST /api/user-words/study - Increments study count
✅ GET /api/user-words/stats - Returns accurate statistics
✅ GET /api/user-words/bookmarked - Returns bookmarked words with definitions

## Technical Implementation Details

### Database Design Pattern
- Uses `word` (string) as the unique key for UPSERT operations
- Stores `wordlist_id` in `word_id` column for reference
- LEFT JOIN between `word_lists` and `word_study_progress` to merge data
- All upserts use: `ON CONFLICT (user_id, word) DO UPDATE SET ...`

### API Pattern
All POST endpoints follow this pattern:
1. Validate request parameters
2. Fetch `word` string from `word_lists` using `wordlist_id`
3. UPSERT into `word_study_progress` using `(user_id, word)` as conflict key
4. Update `last_studied_at` timestamp
5. Return updated record

### Flutter Pattern
- Provider loads progress on ISBN change
- WordCard merges API data with local Word entity
- UI updates optimistically with loading states
- Errors displayed via SnackBar

## Files Modified/Created

### Backend
- ✏️ Modified: `/home/syrikx0/reading-turtle/server.js` (lines 575-879)
  - Added 6 new API endpoints
- ✏️ Modified: `/home/syrikx0/reading-turtle/alter_word_study_progress.sql`
  - Database migration script
- 📄 Created: `/home/syrikx0/reading-turtle/docs/user-word-api-spec.md`
  - Complete API specification

### Flutter
- 📄 Created: `lib/presentation/providers/user_word_state.dart`
- 📄 Created: `lib/data/api/user_word_api_service.dart`
- 📄 Created: `lib/presentation/providers/user_word_provider.dart`
- ✏️ Modified: `lib/domain/entities/word.dart`
- ✏️ Modified: `lib/data/models/word_model.dart`
- ✏️ Modified: `lib/presentation/widgets/word_card_widget.dart`
- ✏️ Modified: `lib/presentation/screens/word_study/word_study_screen.dart`

## Known Issues & Limitations

1. The API returns stats counts as strings instead of integers (PostgreSQL COUNT returns text)
2. Legacy columns (`completed`, `completed_at`) still exist for backward compatibility
3. Server startup message shows database as "booktaco" but actually uses "readingturtle"

## Future Enhancements

1. Add pagination for bookmarked words list
2. Add sorting options (by date, alphabetically, etc.)
3. Add bulk operations (mark all as known, clear all bookmarks)
4. Add word review reminders based on spaced repetition
5. Add word difficulty levels based on study patterns
6. Export/import word lists
7. Share bookmarked words with other users

## Server Configuration

**Database**: PostgreSQL (readingturtle)
**Port**: 8010
**Authentication**: JWT with Bearer token
**Server Process**: Running as background process (PID varies)

## Deployment Notes

To deploy this feature:
1. Run database migration: `psql readingturtle < alter_word_study_progress.sql`
2. Restart server: `pkill -f "node server.js" && node server.js > server.log 2>&1 &`
3. Build Flutter app: `flutter pub run build_runner build --delete-conflicting-outputs`
4. Test all endpoints with valid JWT token

## Contact

Implemented by: Claude Code
Database: turtle_user@localhost/readingturtle
Git User: syrikx <syrikx@gmail.com>
