# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[TODO: Add a brief description of what this project does and its main purpose]

## Development Setup

### Git Configuration
- User name: syrikx
- User email: syrikx@gmail.com

[TODO: Add setup instructions, dependencies, and prerequisites]

## Common Commands

### Build
[TODO: Add build command, e.g., `npm run build` or `python -m build`]

### Test
[TODO: Add test commands]
- Run all tests: [command]
- Run single test: [command]

### Lint/Format
[TODO: Add linting and formatting commands]

### Run/Serve
[TODO: Add commands to run the application]

## Architecture

This project follows the MVVM (Model-View-ViewModel) architectural pattern.

### State Management
- Use global state management
- For Flutter: Use Riverpod for state management

### Key Components
[TODO: Describe major components and how they interact]

### Data Flow
[TODO: Explain how data flows through the system]

## Important Conventions

### Development Guidelines
- Do NOT create mock data, mock pages, or mock views
- When deleting files or folders:
  - First check the number of affected files
  - Get user approval before proceeding with deletion
- Database: This project uses PostgreSQL

### Development Methodology
- Follow TDD (Test-Driven Development) approach
- Always save all test code
- Create separate MD files for explanations that users need to understand
- Document the following in MD files for future sessions:
  - Data types
  - API endpoints
  - Folder structures and document names
  - Any other information that would help continue development in the next Claude session

### Installation Documentation
- When installing modules with apt, pip, etc., record the installation commands in MD files
- For large-scale installations (e.g., PostgreSQL, Flutter, etc.):
  - Create MD files with user guidance and installation instructions
  - Include setup steps and configuration details

### Command Documentation
- Record all executed bash shell commands in separate MD files
- Record all executed SQL commands in separate MD files

## Critical Checklist: ALWAYS Follow This Before Completing Any Task

### ⚠️ MANDATORY PRE-COMPLETION CHECKLIST ⚠️

**IMPORTANT**: This checklist MUST be followed for EVERY task involving backend, database, or API changes. These errors have occurred repeatedly and MUST be prevented.

#### 1. Database Changes Checklist

When creating new tables or modifying database:

- [ ] **Check Primary Key Column Name**
  - Verify existing table PK naming convention (e.g., `user_id`, not `id`)
  - Use `\d table_name` to check existing tables
  - Common pattern in this project: `{table_name}_id` (e.g., `post_id`, `reply_id`, `user_id`)

- [ ] **Grant Permissions to Database User**
  ```sql
  -- For new tables, ALWAYS run:
  GRANT ALL PRIVILEGES ON TABLE table_name TO turtle_user;
  GRANT USAGE, SELECT ON SEQUENCE table_name_id_seq TO turtle_user;
  ```

- [ ] **Verify Foreign Key References**
  - Check that FK references use correct column names from parent tables
  - Example: Use `user_id` not `id` when referencing `users` table

#### 2. Backend API Checklist

When creating new API endpoints:

- [ ] **Verify API Routes Match Frontend**
  - Double-check endpoint paths in backend match what frontend expects
  - Confirm HTTP methods (GET, POST, PUT, DELETE) are correct

- [ ] **Test Authentication Middleware**
  - Ensure `authenticateToken` is applied where needed
  - Test with actual login token, not just curl

- [ ] **Check Database Column Names in Queries**
  - Verify column names match actual database schema
  - Use snake_case for DB columns (e.g., `post_id`, `created_at`)
  - Use camelCase for JSON responses if needed

- [ ] **Test Error Responses**
  - 401 for unauthorized
  - 404 for not found
  - 403 for forbidden
  - 400 for bad request

#### 3. Flutter/Frontend Checklist

When adding new features to Flutter:

- [ ] **Add Missing Dependencies**
  - Check if new packages are needed (e.g., `intl` for date formatting)
  - Run `flutter pub add package_name` BEFORE writing code that uses it

- [ ] **Generate Code for freezed/json_serializable**
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- [ ] **Update Router Configuration**
  - Add imports for new screens
  - Add routes in `router_config.dart`
  - Test navigation paths

- [ ] **Field Name Consistency**
  - Backend sends snake_case (e.g., `post_id`, `created_at`)
  - Model fromJson must parse snake_case to camelCase
  - Verify all fields are mapped correctly

#### 4. Testing Checklist

Before marking task as complete:

- [ ] **Test Full CRUD Flow**
  - Create: Can create new records?
  - Read: Can fetch list and single item?
  - Update: Can modify existing records?
  - Delete: Can remove records?

- [ ] **Test with Real User Session**
  - Login with actual user
  - Test all features with authenticated session
  - Verify permissions work correctly

- [ ] **Check Server Logs**
  ```bash
  tail -50 /home/syrikx0/reading-turtle/server_latest.log | grep -i error
  ```

- [ ] **Verify Database State**
  ```bash
  sudo -u postgres psql -d readingturtle -c "SELECT * FROM table_name LIMIT 5;"
  ```

#### 5. Documentation Checklist

- [ ] **Update Feature Documentation**
  - Create MD file in `/docs` folder
  - Document API endpoints
  - Document database schema
  - Document folder structure

- [ ] **Record Commands**
  - Save SQL schema in `.sql` file
  - Document any special setup steps

## Common Pitfalls to Avoid

### Database
1. ❌ Using `id` instead of `{table}_id` for primary keys
2. ❌ Forgetting to grant permissions to `turtle_user`
3. ❌ Wrong foreign key column names

### Backend
1. ❌ Not testing with authentication token
2. ❌ Column name mismatches (snake_case vs camelCase)
3. ❌ Missing error handling

### Frontend
1. ❌ Missing package dependencies
2. ❌ Not running build_runner after adding freezed classes
3. ❌ Field mapping errors in fromJson methods

## Troubleshooting Quick Reference

### Permission Denied Errors
```bash
# Grant table permissions
sudo -u postgres psql -d readingturtle -c "GRANT ALL PRIVILEGES ON TABLE table_name TO turtle_user;"

# Grant sequence permissions
sudo -u postgres psql -d readingturtle -c "GRANT USAGE, SELECT ON SEQUENCE table_name_id_seq TO turtle_user;"
```

### Flutter Package Issues
```bash
# Clean and reinstall
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Server Issues
```bash
# Restart server
pkill -f "node.*server.js"
cd /home/syrikx0/reading-turtle && node server.js > server_latest.log 2>&1 &
```

[TODO: Add additional project-specific conventions, patterns, or practices that aren't obvious from reading individual files]
