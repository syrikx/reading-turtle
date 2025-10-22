# User Word Study API Specification

## Overview
APIs for tracking user's word study progress, bookmarks, and statistics.

## Authentication
All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

## Endpoints

### 1. Get User Word Progress for a Book
Get all word progress data for a specific book.

**Endpoint:** `GET /api/user-words/progress/:isbn`

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

**Database Schema Needed:**
```sql
CREATE TABLE user_word_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  word_id INTEGER NOT NULL,
  is_known BOOLEAN DEFAULT FALSE,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  last_studied_at TIMESTAMP,
  study_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, word_id)
);

CREATE INDEX idx_user_word_progress_user ON user_word_progress(user_id);
CREATE INDEX idx_user_word_progress_word ON user_word_progress(word_id);
```

---

### 2. Toggle Word Known Status
Mark a word as known or unknown.

**Endpoint:** `POST /api/user-words/known`

**Request Body:**
```json
{
  "word_id": 123,
  "is_known": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Word status updated",
  "data": {
    "word_id": 123,
    "is_known": true,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

**Logic:**
- If user_word_progress record exists: UPDATE
- If not exists: INSERT
- Always update `last_studied_at` to current timestamp

---

### 3. Toggle Word Bookmark
Bookmark or unbookmark a word.

**Endpoint:** `POST /api/user-words/bookmark`

**Request Body:**
```json
{
  "word_id": 123,
  "is_bookmarked": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Bookmark updated",
  "data": {
    "word_id": 123,
    "is_bookmarked": true,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

**Logic:**
- If user_word_progress record exists: UPDATE
- If not exists: INSERT
- Always update `last_studied_at` to current timestamp

---

### 4. Record Word Study
Increment study count for a word.

**Endpoint:** `POST /api/user-words/study`

**Request Body:**
```json
{
  "word_id": 123
}
```

**Response:**
```json
{
  "success": true,
  "message": "Study recorded",
  "data": {
    "word_id": 123,
    "study_count": 4,
    "last_studied_at": "2025-01-15T10:30:00Z"
  }
}
```

**Logic:**
- If user_word_progress record exists: INCREMENT study_count
- If not exists: INSERT with study_count = 1
- Always update `last_studied_at` to current timestamp

---

### 5. Get User Word Statistics
Get overall word study statistics for the current user.

**Endpoint:** `GET /api/user-words/stats`

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_words": 150,
    "known_words": 45,
    "bookmarked_words": 12,
    "studied_words": 78
  }
}
```

**Logic:**
- `total_words`: COUNT(DISTINCT word_id) from user_word_progress
- `known_words`: COUNT where is_known = true
- `bookmarked_words`: COUNT where is_bookmarked = true
- `studied_words`: COUNT where study_count > 0

---

### 6. Get Bookmarked Words
Get all bookmarked words for the current user.

**Endpoint:** `GET /api/user-words/bookmarked`

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

**Logic:**
- JOIN user_word_progress with words table
- WHERE is_bookmarked = true
- ORDER BY last_studied_at DESC

---

## Error Responses

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Unauthorized. Please login."
}
```

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Missing required field: word_id"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Database error: <error details>"
}
```

---

## Implementation Notes

1. All endpoints should check JWT authentication first
2. Use transactions for UPDATE/INSERT operations
3. Use `ON CONFLICT (user_id, word_id) DO UPDATE` for upsert operations
4. Timestamps should be in UTC
5. Return appropriate HTTP status codes (200, 400, 401, 500)
