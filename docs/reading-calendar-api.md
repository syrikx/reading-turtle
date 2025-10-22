# Reading Calendar API Documentation

## Overview
The Reading Calendar feature allows users to track their daily reading sessions with detailed information including pages read, time spent, and notes.

## Database Schema

### Table: `reading_sessions`
```sql
CREATE TABLE reading_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    session_date DATE NOT NULL,
    pages_read INTEGER DEFAULT 0,
    reading_minutes INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (isbn) REFERENCES books(isbn),
    UNIQUE (user_id, isbn, session_date)
);
```

## API Endpoints

### 1. Get Reading Sessions for a Month
**Endpoint:** `GET /api/reading/calendar`

**Authentication:** Required (JWT token)

**Query Parameters:**
- `year` (required): Year (e.g., 2025)
- `month` (required): Month (1-12)

**Response:**
```json
{
  "success": true,
  "sessions": [
    {
      "session_id": 1,
      "session_date": "2025-10-21",
      "pages_read": 70,
      "reading_minutes": 80,
      "notes": "Today's reading session",
      "isbn": "9781570916533",
      "title": "Sneeze!",
      "author": "Some Author",
      "img": "http://localhost:8010/bookimg/9781570916533.jpg",
      "total_pages": 32
    }
  ]
}
```

### 2. Get Sessions for a Specific Date
**Endpoint:** `GET /api/reading/calendar/date/:date`

**Authentication:** Required (JWT token)

**Path Parameters:**
- `date`: Date in format YYYY-MM-DD (e.g., 2025-10-21)

**Response:**
```json
{
  "success": true,
  "sessions": [
    {
      "session_id": 1,
      "session_date": "2025-10-21",
      "pages_read": 70,
      "reading_minutes": 80,
      "notes": "Today's reading session",
      "isbn": "9781570916533",
      "title": "Sneeze!",
      "author": "Some Author",
      "img": "http://localhost:8010/bookimg/9781570916533.jpg",
      "total_pages": 32
    }
  ]
}
```

### 3. Add or Update Reading Session
**Endpoint:** `POST /api/reading/session`

**Authentication:** Required (JWT token)

**Request Body:**
```json
{
  "isbn": "9781570916533",
  "sessionDate": "2025-10-21",
  "pagesRead": 70,
  "readingMinutes": 80,
  "notes": "Today's reading session"
}
```

**Response:**
```json
{
  "success": true,
  "session": {
    "session_id": 1,
    "user_id": 1,
    "isbn": "9781570916533",
    "session_date": "2025-10-21",
    "pages_read": 70,
    "reading_minutes": 80,
    "notes": "Today's reading session",
    "created_at": "2025-10-21T13:55:46.914806Z",
    "updated_at": "2025-10-21T13:55:46.914806Z"
  },
  "message": "독서 기록이 추가되었습니다."
}
```

### 4. Delete Reading Session
**Endpoint:** `DELETE /api/reading/session/:sessionId`

**Authentication:** Required (JWT token)

**Path Parameters:**
- `sessionId`: The ID of the session to delete

**Response:**
```json
{
  "success": true,
  "message": "독서 기록이 삭제되었습니다."
}
```

## Flutter Implementation

### Models
- `ReadingSession`: Main model for reading session data
- `ReadingSessionRequest`: Request model for creating/updating sessions

### Providers
- `readingSessionServiceProvider`: Service provider for API calls
- `monthReadingSessionsProvider`: Provider for fetching monthly sessions
- `dateReadingSessionsProvider`: Provider for fetching sessions by date
- `selectedDateProvider`: State provider for selected date
- `focusedMonthProvider`: State provider for focused month

### Screens
- `ReadingCalendarScreen`: Main calendar view with date selection and session list

### Routes
- `/reading-calendar`: Access the reading calendar screen

## Usage

### Accessing the Calendar
1. User must be logged in
2. Navigate to home screen
3. Click "Reading Calendar" button
4. Or use navigation: `context.go('/reading-calendar')`

### Viewing Sessions
1. Select a date on the calendar
2. View all reading sessions for that date
3. See book cover, title, pages read, and time spent

### Adding Sessions
Currently, sessions need to be added via API or database directly. Future enhancement will include a UI form for adding sessions.

## Test Data
Sample data can be inserted using `insert_sample_reading_sessions.sql`:
```bash
sudo -u postgres psql -d readingturtle < insert_sample_reading_sessions.sql
```

## Future Enhancements
1. Add UI for creating/editing sessions
2. Add statistics view (total pages, total time, streak)
3. Add filtering by book
4. Add export functionality
5. Add goal setting and tracking
6. Add reading reminders
