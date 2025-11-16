# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ReadingTurtle is a reading habit management and tracking system with 121,000+ books. It consists of:
- **Backend**: Node.js/Express REST API with PostgreSQL
- **Frontend**: Flutter mobile/web app (migrating from HTML/JS)
- **Data Pipeline**: Python scripts for crawling book/quiz/word data from BookTaco API

**Current Migration Status**: ~62% complete (Flutter app replacing legacy HTML/JS frontend)

## Development Setup

### Git Configuration
- User name: syrikx
- User email: syrikx@gmail.com

### Prerequisites
- Node.js 16+ (for backend)
- PostgreSQL 14+ (database)
- Flutter 3.4+ (for mobile app)
- Python 3.12+ (for data crawling)

### Initial Setup

```bash
# 1. Install Node dependencies
npm install

# 2. Start PostgreSQL and create database
sudo -u postgres psql
CREATE DATABASE readingturtle;
CREATE USER turtle_user WITH PASSWORD 'ares82';
GRANT ALL PRIVILEGES ON DATABASE readingturtle TO turtle_user;

# 3. Apply database schemas (in order)
sudo -u postgres psql -d readingturtle -f schema_users.sql
sudo -u postgres psql -d readingturtle -f schema_words.sql
sudo -u postgres psql -d readingturtle -f create_quiz_tables.sql
# ... apply other schema files as needed

# 4. Grant table permissions (CRITICAL - do this for ALL new tables)
sudo -u postgres psql -d readingturtle -c "GRANT ALL PRIVILEGES ON TABLE table_name TO turtle_user;"
sudo -u postgres psql -d readingturtle -c "GRANT USAGE, SELECT ON SEQUENCE table_name_id_seq TO turtle_user;"

# 5. Setup Flutter app
cd flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Common Commands

### Backend (Node.js)

```bash
# Start server (production)
npm start

# Development mode with auto-reload
npm run dev

# Start in background and log output
node server.js > server_latest.log 2>&1 &

# Check server logs
tail -f server_latest.log
tail -50 server_latest.log | grep -i error

# Stop background server
pkill -f "node.*server.js"
```

**Backend runs on**: `http://localhost:8010`

### Flutter App

```bash
# Get dependencies
cd flutter
flutter pub get

# Run build_runner for code generation (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on web (development)
flutter run -d web-server --web-port 8080

# Build for production
flutter build web
flutter build apk
flutter build ios

# Run tests
flutter test
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Flutter web runs on**: `http://localhost:8080`

### Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql -d readingturtle

# Check table structure
\d table_name

# Common queries
SELECT * FROM users LIMIT 5;
SELECT * FROM books WHERE bt_level = 3 LIMIT 10;

# Export schema
pg_dump -U postgres -d readingturtle --schema-only > schema_backup.sql
```

### Python Data Scripts

```bash
# Activate virtual environment
source venv/bin/activate

# Import books data
python3 import_to_postgres.py

# Crawl quiz data
python3 save_quiz_to_db_async.py

# Crawl word data
python3 save_words_to_db_async.py
```

## Architecture

### Backend Architecture (Node.js + Express)

**Server**: `server.js` (single file, ~2900 lines)

**Database**: PostgreSQL with connection pooling
- User: `turtle_user`
- Database: `readingturtle`
- Port: 5432

**Authentication**: JWT tokens
- Secret: `booktaco-secret-key-change-in-production`
- Token stored in cookies or `Authorization: Bearer <token>` header
- Middleware: `authenticateToken()`, `optionalAuth()`

**Key Database Tables**:
- `users` - User accounts (PK: `user_id`)
- `books` - Book catalog (PK: `isbn`)
- `quizzes`, `quiz_questions` - Reading comprehension quizzes
- `word_definitions`, `word_lists` - Vocabulary data
- `user_word_progress` - Word study tracking
- `reading_history` - Reading status tracking
- `reading_sessions` - Daily reading calendar (PK: `session_id`)
- `support_posts`, `support_replies` - Customer support board (PK: `post_id`, `reply_id`)

### Flutter Architecture (Clean Architecture)

**Directory Structure**:
```
flutter/lib/
├── core/               # Shared utilities, config, constants
│   ├── config/        # API URLs, router config
│   ├── constants/     # Storage keys, app constants
│   └── utils/         # API client, storage service, analytics
├── domain/            # Business entities (Freezed models)
│   ├── entities/      # User, Book, Quiz, Word, etc.
│   └── repositories/  # Repository interfaces
├── data/              # Data layer implementation
│   ├── api/          # API service classes (Dio)
│   ├── models/       # Data models with JSON serialization
│   └── repositories/ # Repository implementations
├── presentation/      # UI layer
│   ├── screens/      # Full-screen pages
│   ├── widgets/      # Reusable components
│   └── providers/    # Riverpod state management
└── features/          # Feature-specific modules
```

**State Management**: Riverpod + Freezed
- Use `StateNotifier` for complex state
- Use `FutureProvider` for async data loading
- Use `StateProvider` for simple state

**HTTP Client**: Dio with interceptors
- Base URL: `http://localhost:8010` (development)
- JWT token auto-injection via interceptor
- Error handling with custom exceptions

**Routing**: GoRouter with authentication guards
- Routes: `/`, `/login`, `/signup`, `/search`, `/quiz/:isbn`, `/words/:isbn`, `/reading-calendar`, `/support`, etc.
- Redirect unauthenticated users to `/login` for protected routes

**Code Generation**:
- `freezed` - Immutable models with copyWith, equality
- `json_serializable` - JSON serialization/deserialization
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after model changes

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create account (username, email, password, fullName)
- `POST /api/auth/login` - Login (username, password) → returns JWT token
- `POST /api/auth/logout` - Logout (clears cookie)
- `GET /api/auth/me` - Get current user info (requires auth)

### Books & Search
- `GET /api/books/search` - Search books (query params: q, genre, btLevel, lexile, hasQuiz, hasWords)
- `GET /api/books/search-count` - Get search result count
- `GET /api/books/browse` - Browse with filters (no query required)
- `GET /api/books/:isbn` - Get book details
- `GET /api/books/:isbn/quizzes` - Get quizzes for a book
- `GET /api/books/:isbn/words` - Get word list for a book

### Word Study (requires auth)
- `GET /api/user-words/progress/:isbn` - Get user's word progress for a book
- `POST /api/user-words/known` - Mark word as known/unknown
- `POST /api/user-words/bookmark` - Bookmark/unbookmark word
- `POST /api/user-words/study` - Record word study (increments count)
- `GET /api/user-words/stats` - Get overall word study stats
- `GET /api/user-words/bookmarked` - Get all bookmarked words
- `GET /api/words/study` - Get words by BT level/Lexile for study

### Word Quiz (requires auth)
- `GET /api/quiz/user-words` - Generate quiz from user's studied words
- `GET /api/quiz/wrong-answers` - Get quiz with previously wrong answers
- `POST /api/quiz/wrong-answer` - Record wrong answer
- `GET /api/quiz/wrong-answers/list` - List all wrong answers
- `DELETE /api/quiz/wrong-answer/:word_id` - Remove from wrong answers

### Reading Tracking (requires auth)
- `POST /api/reading/status` - Add/update reading status (started, reading, completed)
- `GET /api/reading/history` - Get user's reading history
- `GET /api/reading/status/:isbn` - Get reading status for a book
- `GET /api/reading/stats` - Get reading statistics

### Reading Calendar (requires auth)
- `GET /api/reading/calendar` - Get reading sessions for a month (query: year, month)
- `GET /api/reading/calendar/date/:date` - Get sessions for specific date
- `POST /api/reading/session` - Add/update reading session
- `DELETE /api/reading/session/:sessionId` - Delete reading session

### Customer Support (requires auth)
- `GET /api/support/posts` - List user's support posts
- `GET /api/support/posts/:postId` - Get post with replies
- `POST /api/support/posts` - Create new support post
- `PUT /api/support/posts/:postId` - Update support post
- `DELETE /api/support/posts/:postId` - Delete support post
- `POST /api/support/posts/:postId/replies` - Add reply to post

## Development Conventions

### Database
- **Primary Key Naming**: Use `{table_name}_id` (e.g., `user_id`, `post_id`, `session_id`)
  - **NEVER** use generic `id` - check existing tables with `\d table_name` first
- **Column Names**: Use `snake_case` (e.g., `created_at`, `bt_level`, `full_name`)
- **Timestamps**: Always include `created_at` and `updated_at` (UTC)
- **Foreign Keys**: Reference correct PK column names (e.g., `user_id` not `id`)

### Backend (Node.js)
- **Field Naming**: Backend uses snake_case in database, camelCase in JSON responses
- **Authentication**: Always use `authenticateToken` middleware for protected routes
- **Error Handling**: Return proper HTTP status codes (200, 400, 401, 403, 404, 500)
- **Response Format**: `{ success: true/false, message: "...", data: {...} }`
- **Testing**: Test with curl/Postman using actual JWT tokens from `/api/auth/login`

### Flutter
- **Models**: Use Freezed for all domain entities and state classes
- **JSON**: Use json_serializable, run build_runner after changes
- **Naming**: Use camelCase for Dart (maps from snake_case via `@JsonKey`)
- **Dependencies**: Add to `pubspec.yaml` BEFORE writing code that uses them
- **State**: One feature = one StateNotifier + one State class
- **Errors**: Handle API errors gracefully with user-friendly messages

### Testing
- **TDD Approach**: Write tests before implementation when possible
- **Test Structure**: `test/unit/`, `test/widget/`, `test/integration/`
- **Coverage**: Test repository layer, state notifiers, and critical widgets

### Documentation
- **Record Everything**: Create MD files for features, APIs, installation steps
- **SQL Commands**: Save schema changes in `.sql` files
- **Bash Commands**: Document important commands in MD files
- **Data Types**: Document models, entities, and API contracts

## Critical Pre-Completion Checklist

**ALWAYS verify before marking ANY task complete**:

### Database Changes
- [ ] Check PK naming convention (`\d table_name` on existing tables)
- [ ] Use `{table_name}_id` pattern (e.g., `user_id`, `post_id`, `session_id`)
- [ ] Grant permissions to `turtle_user` for new tables/sequences
  ```sql
  GRANT ALL PRIVILEGES ON TABLE table_name TO turtle_user;
  GRANT USAGE, SELECT ON SEQUENCE table_name_id_seq TO turtle_user;
  ```
- [ ] Verify FK references use correct column names from parent tables

### Backend API
- [ ] Verify route paths match frontend expectations exactly
- [ ] Apply `authenticateToken` middleware where needed
- [ ] Test with real JWT token, not just curl
- [ ] Check column names match database schema (snake_case)
- [ ] Return proper error codes (401, 403, 404, 400, 500)

### Flutter Frontend
- [ ] Add missing packages to `pubspec.yaml` FIRST
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs` after model changes
- [ ] Update `router_config.dart` with new routes and imports
- [ ] Verify `fromJson` maps snake_case API fields to camelCase Dart fields
- [ ] Test navigation paths end-to-end

### Testing & Verification
- [ ] Test full CRUD flow (Create, Read, Update, Delete)
- [ ] Test with authenticated user session
- [ ] Check server logs: `tail -50 server_latest.log | grep -i error`
- [ ] Verify database state: `sudo -u postgres psql -d readingturtle -c "SELECT * FROM table_name LIMIT 5;"`

### Documentation
- [ ] Update/create feature MD file in `/docs`
- [ ] Save SQL schema in `.sql` file
- [ ] Document API endpoints and request/response formats

## Common Pitfalls

### Database
- ❌ Using `id` instead of `{table}_id` for primary keys
- ❌ Forgetting to grant permissions to `turtle_user` (causes "permission denied" errors)
- ❌ Wrong FK column names (e.g., referencing `id` when parent uses `user_id`)

### Backend
- ❌ Not testing with authentication token (routes return 401)
- ❌ Column name mismatches between code and database
- ❌ Missing error handling (unhandled exceptions crash server)

### Flutter
- ❌ Using packages without adding to `pubspec.yaml` (import errors)
- ❌ Not running build_runner after Freezed/JSON changes (missing `.g.dart` files)
- ❌ Field mapping errors in `fromJson` methods (snake_case vs camelCase)

## Troubleshooting

### Permission Denied Errors
```bash
# Grant table permissions
sudo -u postgres psql -d readingturtle -c "GRANT ALL PRIVILEGES ON TABLE table_name TO turtle_user;"

# Grant sequence permissions
sudo -u postgres psql -d readingturtle -c "GRANT USAGE, SELECT ON SEQUENCE table_name_id_seq TO turtle_user;"
```

### Flutter Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Server Issues
```bash
# Restart server
pkill -f "node.*server.js"
cd /home/syrikx0/reading-turtle-v2 && node server.js > server_latest.log 2>&1 &

# Check logs
tail -f server_latest.log
```

### Database Connection Issues
```bash
# Test connection
sudo -u postgres psql -d readingturtle -c "SELECT current_database();"

# Check if server is listening
netstat -an | grep 5432
```

## Production Deployment

### Domain & Directory Structure

**Directories**:
- `/home/syrikx0/reading-turtle` → **Production** (stable releases)
- `/home/syrikx0/reading-turtle-v2` → **Development** (active development)

**Domains** (nginx reverse proxy):
- `reading-turtle.com` → Port 8080 → **Production** (`/home/syrikx0/reading-turtle`)
- `v2.reading-turtle.com` → Port 8090 → **Development** (`/home/syrikx0/reading-turtle-v2`)

**Ports**:
- **8080**: Production Flutter web (reading-turtle)
- **8090**: Development Flutter web (reading-turtle-v2)
- **8010**: Backend API server (shared, runs from reading-turtle-v2)

### Version Management

**Current Version**: See `flutter/lib/core/constants/app_version.dart`

**Version Update Process**:
1. Before each production deployment, increment version in `app_version.dart`
2. Use semantic versioning: `MAJOR.MINOR.PATCH` (e.g., 1.0.1 → 1.0.2)
3. Version is displayed in Customer Support page footer

**Version History**:
- v1.0.1 - Interactive tutorials, splash/onboarding, monthly calendar (2025-11-16)

### Deployment Workflow

**Step-by-step process** when deploying to production:

```bash
# 1. Develop in reading-turtle-v2
cd /home/syrikx0/reading-turtle-v2

# 2. Update version in app_version.dart
# Edit flutter/lib/core/constants/app_version.dart
# Change version string (e.g., '1.0.1' → '1.0.2')

# 3. Test on development server
# Access v2.reading-turtle.com to verify changes

# 4. Commit and push
git add -A
git commit -m "Release vX.X.X: Description"
git push origin main

# 5. Deploy to production
cd /home/syrikx0/reading-turtle
git stash  # Save any local changes
git pull origin main
cd flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web

# 6. Verify deployment
# Access reading-turtle.com
# Check version in Customer Support page
```

### Server Management

```bash
# Check running processes
ps aux | grep "node.*server.js" | grep -v grep    # Node.js backend
netstat -tlnp | grep ":8080"                       # Production web server
netstat -tlnp | grep ":8090"                       # Development web server
netstat -tlnp | grep ":8010"                       # Backend API

# Start/Stop Flutter web servers
## Production (port 8080)
cd /home/syrikx0/reading-turtle/flutter/build/web
nohup python3 -m http.server 8080 --bind 0.0.0.0 > /dev/null 2>&1 &
pkill -f "python3 -m http.server 8080"

## Development (port 8090)
cd /home/syrikx0/reading-turtle-v2/flutter/build/web
nohup python3 -m http.server 8090 --bind 0.0.0.0 > /dev/null 2>&1 &
pkill -f "python3 -m http.server 8090"

# Restart Node.js backend
pkill -f "node.*server.js"
cd /home/syrikx0/reading-turtle-v2
node server.js > server_latest.log 2>&1 &

# Check nginx configuration
sudo nginx -T | grep -A 10 "reading-turtle.com"

# Reload nginx (after config changes)
sudo nginx -t && sudo nginx -s reload
```

### SSL Certificates

- Managed by Certbot (Let's Encrypt)
- Certificate path: `/etc/letsencrypt/live/reading-turtle.com/`
- Auto-renewal configured

## Migration Status & Next Steps

**Current Progress**: 62% complete (45/85 features implemented)

**Completed**:
- ✅ Authentication (login, signup, JWT)
- ✅ Book search with filters
- ✅ Quiz viewing
- ✅ Word viewing by book
- ✅ Reading calendar
- ✅ Customer support board

**High Priority TODO**:
- Reading status tracking (started/reading/completed)
- My Page with statistics
- Level-based word study (BT/Lexile selection)
- Word quiz generation system
- Lexile filter for book search

See `/docs/implementation-status.md` for detailed feature parity tracking.

## External Resources

- **BookTaco API**: Source for book/quiz/word data
- **Firebase Analytics**: Integrated for cross-platform analytics
- **Google Analytics 4**: Web analytics (legacy, migrating to Firebase)
