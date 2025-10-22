# ReadingTurtle Feature Specification

## Document Information
- **Project**: ReadingTurtle
- **Document Type**: Feature Specification
- **Last Updated**: 2025-10-19
- **Source**: index.html (3874 lines)

---

## Table of Contents
1. [Overview](#overview)
2. [Authentication System](#authentication-system)
3. [Book Search & Browse](#book-search--browse)
4. [Book Management](#book-management)
5. [Quiz System](#quiz-system)
6. [Word Study System](#word-study-system)
7. [Word Quiz System](#word-quiz-system)
8. [My Page & Reading History](#my-page--reading-history)
9. [API Endpoints Summary](#api-endpoints-summary)
10. [UI Components Summary](#ui-components-summary)

---

## Overview

**ReadingTurtle** is an English reading learning platform that provides:
- Book search with AR/BT level and Lexile filtering
- Reading comprehension quizzes
- Vocabulary learning with example sentences
- Reading progress tracking
- Personalized word study based on reading level

**Technology Stack**: Single-page application (SPA) using vanilla JavaScript, HTML, CSS

---

## 1. Authentication System

### 1.1 Features
- **User Registration** (handled in separate auth.html)
- **User Login** (handled in separate auth.html)
- **User Logout**
- **Session Management** with JWT tokens
- **Auto-login** on page load if token exists

### 1.2 User Flows

#### Login Flow
1. User clicks "로그인 / 회원가입" button
2. Redirected to `/auth.html`
3. After successful login, token stored in localStorage
4. Redirected back to main page
5. User info displayed in header

#### Logout Flow
1. User clicks "로그아웃" button
2. API call to `/api/auth/logout`
3. Token removed from localStorage
4. UI reset to guest mode
5. Alert notification shown

### 1.3 UI Components
- **Guest Mode**: "로그인 / 회원가입" button
- **Logged-in Mode**:
  - Username display with "👤" icon
  - Clickable username → goes to My Page
  - "로그아웃" button

### 1.4 API Endpoints
```
GET  /api/auth/me              - Get current user info (with Bearer token)
POST /api/auth/logout          - Logout user
```

### 1.5 Storage
```javascript
localStorage.setItem('token', jwt_token);
localStorage.setItem('user', JSON.stringify(user_object));
```

---

## 2. Book Search & Browse

### 2.1 Features

#### Search Types
1. **All** (전체 검색) - Search across all fields
2. **ISBN** - Exact ISBN search
3. **Title** (제목) - Book title search
4. **Author** (저자) - Author name search
5. **Series** (시리즈) - Book series search

#### Filter Options

##### Level Filters (Dual Range Sliders)
- **BT Level**: 0.0 ~ 10.0 (step: 0.5)
- **Lexile**: 0 ~ 1500 (step: 50)
- **Level Condition**: AND / OR toggle
  - AND: Books must match BOTH BT Level AND Lexile ranges
  - OR: Books must match EITHER BT Level OR Lexile range

##### Additional Filters
- **Genre**: All / Fiction / Nonfiction
- **Quiz Availability**: All / Only with quiz

##### Real-time Filter Count
- Shows number of matching books as filters are adjusted
- Updates automatically when:
  - Sliders moved
  - Genre changed
  - Quiz filter toggled
  - Search query entered
- Limit: Maximum 500 books displayable

### 2.2 User Flows

#### Search Flow
1. User enters search query in search input
2. User selects search type from dropdown
3. User optionally adjusts filters (BT level, Lexile, genre, quiz)
4. User clicks "검색" button
5. Results displayed in grid layout
6. Each book card shows:
   - Book image (or placeholder)
   - ISBN
   - Title, Author, Series
   - BT Level, Lexile
   - Quiz availability
   - Action buttons (퀴즈 보기, 단어 보기)
   - Reading status buttons (if logged in)

#### Browse-only Flow (No search query)
1. User adjusts filters without entering search query
2. Filter count shows number of matching books
3. If count ≤ 500: User can click "검색" to browse
4. If count > 500: Alert shown to narrow filters

### 2.3 UI Components

#### Search Section
```html
- Search input field (placeholder: "ISBN, 제목, 저자, 시리즈로 검색하세요...")
- Search type dropdown (all/isbn/title/author/series)
- "검색" button (purple gradient)
- "초기화" button (gray)
```

#### Level Filters Section
```html
- BT Level dual-range slider (0-10)
  - Reset button (전체)
  - Visual progress bar
  - Current values display

- Lexile dual-range slider (0-1500)
  - Reset button (전체)
  - Visual progress bar
  - Current values display

- Level condition toggle (AND/OR buttons)
- Genre filter buttons (전체/Fiction/Nonfiction)
- Quiz filter buttons (전체/있음만)
- Filter count badge (e.g., "매칭: 42 권")
```

#### Results Section
```html
- Results header
  - Title: "검색 결과" or query-specific title
  - Count badge: "X개 결과"

- Book grid (responsive, auto-fill, min 300px cards)
  - Book cards (see Book Card Components below)
```

### 2.4 Book Card Components

#### Standard Book Card (Guest Mode)
```html
- Book image container (200px height)
- ISBN badge (purple gradient)
- Title (bold, 1.2rem)
- Info grid:
  - 저자 (Author)
  - 시리즈 (Series)
  - BT 레벨 (with green badge if available)
  - Lexile
  - 퀴즈 (with "✓ 있음" badge if available)
- Action buttons:
  - "퀴즈 보기" (green gradient, disabled if no quiz)
  - "단어 보기" (purple gradient, disabled if no words)
```

#### Book Card with Status (Logged-in Mode)
```html
- All standard components PLUS:
- Status badge (읽기 시작/읽는 중/읽음)
- Reading status buttons:
  - "읽기 시작" (yellow border when active)
  - "읽는 중" (teal border when active)
  - "읽음" (green border when active)
- Reading dates (if on My Page):
  - 시작: YYYY.MM.DD
  - 읽는중: YYYY.MM.DD
  - 완료: YYYY.MM.DD
```

#### Compact Book Card (Reading Now Section)
```html
- Smaller image (120px height)
- Title (truncated to 2 lines)
- Compact status buttons (시작/진행/완료)
- Compact action buttons (퀴즈/단어)
- Horizontal scroll layout
```

### 2.5 API Endpoints

```
GET /api/books/search
  Query Parameters:
    - q: string (search query)
    - type: string (all|isbn|title|author|series)
    - btLevelMin: number (optional)
    - btLevelMax: number (optional)
    - lexileMin: number (optional)
    - lexileMax: number (optional)
    - genre: string (fiction|nonfiction, optional)
    - hasQuiz: boolean (optional)
    - levelCondition: string (AND|OR)
  Response:
    {
      success: boolean,
      data: [
        {
          isbn: string,
          title: string,
          author: string,
          series: string,
          bt_level: number,
          lexile: number,
          quiz: number (0 or 1),
          has_words: boolean,
          image_url: string,
          status: string (if logged in: started|reading|completed)
        }
      ]
    }

GET /api/books/browse
  Query Parameters: (same as search, but without 'q')
  Response: (same as search)

GET /api/books/filter-count
  Query Parameters: (same as search filters)
  Response:
    {
      success: boolean,
      count: number
    }

GET /api/books/search-count
  Query Parameters: (same as search with query and filters)
  Response:
    {
      success: boolean,
      count: number
    }
```

### 2.6 JavaScript Functions

```javascript
// Core search functions
handleSearch()                    // Main search handler
performSearch(query, type)        // Execute API search
browseByFilters()                 // Browse without query (filter-only)

// Filter functions
updateBTLevelRange()              // Update BT level slider
updateLexileRange()               // Update Lexile slider
resetBTLevelFilter()              // Reset BT level to full range
resetLexileFilter()               // Reset Lexile to full range
setGenre(genre)                   // Set genre filter
setQuizFilter(filter)             // Set quiz availability filter
setLevelCondition(condition)      // Set AND/OR condition
updateFilterCount()               // Update filter count badge
updateFilterCountWithQuery()      // Update count with search query

// Display functions
displayResults(data, query)       // Render search results
createBookCard(book)              // Generate book card HTML
createBookCardWithStatus(book)    // Generate book card with status (logged in)
createCompactBookCard(book)       // Generate compact card (reading now)
```

---

## 3. Book Management

### 3.1 Features

#### Reading Status Management
- **Three Status Levels**:
  1. **Started** (읽기 시작) - Yellow theme
  2. **Reading** (읽는 중) - Teal theme
  3. **Completed** (읽음) - Green theme

#### Reading Now Section
- Shows books with "reading" status
- Displays on home screen when logged in
- Horizontal scroll layout with compact cards
- Quick access to quiz and words

### 3.2 User Flows

#### Add/Update Reading Status
1. User searches for a book or views My Page
2. User clicks one of the status buttons (시작/중/완료)
3. Button text changes to "저장 중..."
4. API call to update status
5. Button returns to normal state
6. Active state indicated by colored background
7. Reading Now section auto-refreshes

### 3.3 UI Components

#### Reading Now Section (Home Screen)
```html
- Header: "📖 읽는 중인 책"
- Horizontal scroll grid of compact book cards
- Only visible when logged in and has reading books
```

#### Reading Status Buttons (Full Card)
```html
- Three buttons in a row
- "읽기 시작" (yellow border/bg when active)
- "읽는 중" (teal border/bg when active)
- "읽음" (green border/bg when active)
- Disabled state during save
```

#### Reading Status Buttons (Compact Card)
```html
- Smaller buttons (compact-status-btn)
- Same three statuses
- Labeled: "시작", "진행", "완료"
```

### 3.4 API Endpoints

```
POST /api/reading/status
  Headers:
    - Authorization: Bearer <token>
  Body:
    {
      isbn: string,
      status: string (started|reading|completed)
    }
  Response:
    {
      success: boolean,
      message: string
    }

GET /api/reading/history
  Headers:
    - Authorization: Bearer <token>
  Query Parameters:
    - status: string (optional: started|reading|completed)
  Response:
    {
      success: boolean,
      data: [
        {
          isbn: string,
          title: string,
          author: string,
          series: string,
          bt_level: number,
          lexile: number,
          quiz: number,
          has_words: boolean,
          image_url: string,
          status: string,
          started_at: datetime,
          reading_at: datetime,
          completed_at: datetime
        }
      ]
    }
```

### 3.5 JavaScript Functions

```javascript
updateReadingStatus(isbn, status, event)  // Update book status
loadReadingNow()                          // Load reading books for home
```

---

## 4. Quiz System

### 4.1 Features

#### Book Quiz Features
- Multiple-choice questions per book
- 4 answer choices per question
- Instant feedback on answer selection
- Shows correct answer after selection
- Visual indicators (correct/incorrect)

### 4.2 User Flows

#### View Quiz Flow
1. User clicks "퀴즈 보기" button on book card
2. Quiz modal opens with loading state
3. Quizzes loaded from API
4. Modal displays:
   - Book info (title, ISBN)
   - Total number of quizzes
   - List of all quiz questions
5. User clicks on an answer choice
6. Choice is disabled, correct answer highlighted
7. Result message shown (정답/틀림)
8. Correct answer explanation displayed

### 4.3 UI Components

#### Quiz Modal
```html
- Modal overlay (semi-transparent black)
- Quiz modal container (white, rounded, centered)
  - Header (pink gradient):
    - Title: "📝 퀴즈 목록"
    - Subtitle: Book title and quiz count
    - Close button (×)
  - Body (scrollable):
    - Loading state
    - Error state
    - Quiz items list
```

#### Quiz Item
```html
- Quiz number badge (purple)
- Question text (bold, large)
- Four choice buttons:
  - Normal state: white background, gray border
  - Hover state: purple border, light purple bg
  - Selected state: blue background
  - Correct state: green background
  - Incorrect state: red background
- Result message (appears after selection):
  - "🎉 정답입니다!" (green) or
  - "❌ 틀렸습니다. 정답을 확인해보세요." (red)
- Answer explanation box (blue):
  - "✅ 정답: [번호]번 - [정답 내용]"
```

### 4.4 API Endpoints

```
GET /api/books/:isbn/quizzes
  Response:
    {
      success: boolean,
      book: {
        isbn: string,
        title: string
      },
      quizzes: [
        {
          question_id: number,
          question_number: number,
          question_text: string,
          choice_1: string,
          choice_2: string,
          choice_3: string,
          choice_4: string,
          correct_choice_number: number,
          correct_answer: string
        }
      ]
    }
```

### 4.5 JavaScript Functions

```javascript
loadQuizzes(isbn)                           // Load quizzes for a book
displayQuizzes(data)                        // Render quiz list
createQuizItem(quiz)                        // Generate quiz item HTML
selectChoice(questionId, selected, correct) // Handle answer selection
openQuizModal()                             // Open quiz modal
closeQuizModal()                            // Close quiz modal
```

---

## 5. Word Study System

### 5.1 Features

#### Word Learning Features
- **Level-based word selection**:
  - Choose by BT Level (0-10) or Lexile (0-1500)
  - Slider to select target level
  - Auto-loads words at or slightly above selected level

- **Word display**:
  - Word with pronunciation level info
  - Korean definition
  - Example sentence
  - Completion checkbox (logged-in users)

- **Progress tracking** (logged-in users):
  - Mark words as completed
  - Filter: All / Incomplete / Completed
  - Progress statistics

- **Pagination**:
  - Load 50 words at a time
  - "더 보기" button to load more

### 5.2 User Flows

#### Word Study Flow
1. User navigates to Word Study (from My Page or home)
2. User selects difficulty criteria:
   - Choose BT Level or Lexile
   - Adjust slider to target level
3. System loads words matching selected level
4. Words displayed in cards with:
   - Serial number
   - Word and level info
   - Definition (Korean)
   - Example sentence
5. (Logged in) User can mark words as completed
6. User can load more words with "더 보기" button
7. User can take a quiz based on studied words

#### Change Level Flow
1. User moves BT Level or Lexile slider
2. Word list auto-refreshes
3. Previously loaded words cleared
4. New words loaded for new level
5. Progress stats updated

#### Completion Toggle Flow (Logged-in only)
1. User clicks "완료" button on word card
2. Button shows loading state
3. API updates completion status
4. Word list refreshes
5. Button shows "✓ 완료" with green background

### 5.3 UI Components

#### Word Study Section
```html
- Header:
  - Title: "📖 단어 공부하기"
  - "마이페이지로" button

- Options Panel (white card):
  - Difficulty Criteria (난이도 기준):
    - "BT Level" button (active by default)
    - "Lexile" button

  - Completion Filter (학습 상태) [logged-in only]:
    - "전체" button
    - "미완료" button
    - "완료" button

  - BT Level Selection (default view):
    - Range slider (0-10, step 0.1)
    - Current value display: "BT Level: X.X"
    - Guide text: "초급(0-3), 중급(3-7), 고급(7-10)"

  - Lexile Selection (when Lexile chosen):
    - Range slider (0-1500, step 50)
    - Current value display: "Lexile: XXX"
    - Guide text: "초급(0-500), 중급(500-800), 고급(800-1500)"

  - "✍️ 단어 시험 보기" button (orange gradient)

- Progress Stats (white card):
  - Total words count
  - Current progress (X / Total)
  - Current sort criteria (BT Level or Lexile)

- Word Cards List:
  - Loading state
  - Error state
  - Word items

- Load More Button:
  - "더 보기" button
  - Shows when more words available
```

#### Word Card
```html
- White card with shadow
- Layout:
  - Left: Serial number (#X)
  - Center:
    - Word (large, bold) with level badge
    - Definition (Korean)
    - Example sentence (italic, gray)
  - Right (logged-in only):
    - Completion button:
      - Uncompleted: white bg, gray border, "완료"
      - Completed: green bg, white text, "✓ 완료"
```

### 5.4 API Endpoints

```
GET /api/words/study
  Query Parameters:
    - sortBy: string (bt_level|lexile)
    - btLevelMin: number (if sortBy = bt_level)
    - btLevelMax: number (if sortBy = bt_level)
    - lexileMin: number (if sortBy = lexile)
    - lexileMax: number (if sortBy = lexile)
    - limit: number (default: 50)
    - offset: number (default: 0)
    - completionFilter: string (all|incomplete|completed) [logged-in only]
  Response:
    {
      success: boolean,
      data: {
        total: number,
        words: [
          {
            word: string,
            definition: string,
            example_sentence: string,
            min_bt_level: number,
            min_lexile: number,
            is_completed: boolean (if logged in)
          }
        ]
      }
    }

POST /api/words/study/toggle
  Headers:
    - Authorization: Bearer <token>
  Body:
    {
      word: string,
      completed: boolean
    }
  Response:
    {
      success: boolean
    }
```

### 5.5 JavaScript Functions

```javascript
goToWordStudy()                        // Navigate to word study page
changeWordSortBy(sortBy)               // Switch between BT/Lexile
updateStudyBTLevel()                   // Update BT level slider
updateStudyLexile()                    // Update Lexile slider
loadStudyWords()                       // Load words from API
loadMoreWords()                        // Load next page of words
renderWordCards(words, clearFirst)     // Render word cards
changeCompletionFilter(filter)         // Filter by completion status
toggleWordCompletion(word, status)     // Toggle word completion
```

### 5.6 Global State

```javascript
wordStudyData = {
  words: [],              // Loaded words
  total: 0,               // Total available words
  currentOffset: 0,       // Pagination offset
  limit: 50,              // Words per page
  sortBy: 'bt_level',     // bt_level or lexile
  btLevel: 1.5,           // Selected BT level
  lexile: 300,            // Selected Lexile
  tolerance: 0.2,         // Level range tolerance
  completionFilter: 'all' // all, completed, incomplete
}
```

---

## 6. Word Quiz System

### 6.1 Features

#### Quiz Generation
- Auto-generates quizzes based on studied level
- Uses same level range as word study
- Multiple-choice format (4 options)
- Randomized answer positions

#### Quiz Format
- **Question**: Korean definition + Example sentence
- **Answer**: English word
- **Choices**: 4 words at similar difficulty level

#### Quiz Progress
- Real-time progress tracking
- Current question number
- Correct answer count
- Accuracy percentage

#### Quiz Results
- Final score display
- Accuracy percentage
- List of wrong answers with:
  - Question number
  - User's selection
  - Correct answer
  - Definition
- Option to retry wrong answers only

### 6.2 User Flows

#### Start Quiz Flow
1. User clicks "✍️ 단어 시험 보기" from Word Study page
2. Quiz auto-starts with studied level
3. First question displayed immediately
4. Progress bar shows: 1 / 10, 0 / 0, 0%

#### Answer Question Flow
1. User reads definition and example sentence
2. User selects one of 4 word choices
3. Selected button highlighted
4. Correct answer shown in green
5. If wrong, wrong answer shown in red
6. 1.5 second pause
7. Next question automatically loaded
8. Progress updated

#### View Results Flow
1. After last question, results screen shown
2. Display:
   - Final score (e.g., "7 / 10")
   - Accuracy (e.g., "70%")
   - List of wrong answers
3. Options:
   - "틀린 문제 다시 풀기" (retry wrong only)
   - "새 시험 보기" (new quiz)
   - "단어 공부로" (back to study)

#### Retry Wrong Answers Flow
1. User clicks "틀린 문제 다시 풀기"
2. Only wrong questions loaded
3. Quiz restarts with wrong questions
4. Same answer flow as above

### 6.3 UI Components

#### Word Quiz Section
```html
- Header:
  - Title: "✍️ 단어 시험"
  - "단어 공부로" button

- Quiz Setup (deprecated, auto-starts now):
  - BT Level range inputs
  - Question count selector
  - "시험 시작하기" button

- Quiz Progress:
  - Progress stats bar (white):
    - "진행: X / Y"
    - "정답: X / Y"
    - "정답률: X%"
  - Question card (white, shadow):
    - Question number
    - Level info badge
    - Definition panel (light purple bg):
      - Korean definition
      - Example sentence (with answer hidden as _____)
    - Instruction: "위 뜻과 예문에 해당하는 단어를 선택하세요:"
    - 4 choice buttons (large, full width)

- Quiz Result:
  - Completion message: "🎉 시험 완료!"
  - Score display (large): "X / Y"
  - Accuracy display: "정답률: X%"
  - Wrong answers list (yellow bg cards):
    - Question number
    - Definition
    - User's wrong answer (red)
    - Correct answer (green)
  - Action buttons:
    - "틀린 문제 다시 풀기" (pink gradient)
    - "새 시험 보기" (purple gradient)
    - "단어 공부로" (gray)
```

#### Quiz Question Card
```html
- Question number (purple text)
- Level badge (gray text): "📊 BT X.X / Lexile XXX"
- Definition panel (light purple background):
  - "뜻:" label
  - Korean definition
  - "예문:" label
  - Example sentence with answer hidden
- Instruction text
- 4 answer choice buttons:
  - Normal: white bg, gray border
  - Hover: purple border, light purple bg
  - Correct: green bg and border, bold text
  - Incorrect: red bg and border
  - All disabled after selection
```

### 6.4 API Endpoints

```
GET /api/words/quiz
  Query Parameters:
    - btLevelMin: number
    - btLevelMax: number
    - count: number (number of questions, default: 10)
  Response:
    {
      success: boolean,
      data: {
        quizzes: [
          {
            questionNumber: number,
            definition: string,
            exampleSentence: string,
            correctAnswer: string,
            choices: [
              { word: string },
              { word: string },
              { word: string },
              { word: string }
            ],
            btLevel: number,
            lexile: number
          }
        ],
        totalQuestions: number,
        btLevelRange: {
          min: number,
          max: number
        }
      }
    }
```

### 6.5 JavaScript Functions

```javascript
goToWordQuiz()                      // Navigate to quiz page
startQuizWithStudiedLevel()         // Auto-start with studied level
startQuiz()                         // Manual start with custom settings
showQuestion()                      // Display current question
answerQuestion(selectedWord)        // Handle answer selection
showResult()                        // Display quiz results
retryWrongAnswers()                 // Restart with wrong questions only
hideAnswerInSentence(sentence, ans) // Replace answer word with ___
```

### 6.6 Global State

```javascript
wordQuizData = {
  quizzes: [],          // Quiz questions
  currentIndex: 0,      // Current question index
  correctCount: 0,      // Number of correct answers
  answeredCount: 0,     // Number of answered questions
  userAnswers: [],      // User's answer history
  wrongQuestions: []    // Indices of wrong questions
}
```

---

## 7. My Page & Reading History

### 7.1 Features

#### Reading Statistics
- Number of books by status:
  - Started (읽기 시작) - Yellow card
  - Reading (읽는 중) - Teal card
  - Completed (읽음) - Green card
  - Total - Blue card

#### Reading History
- Full list of all books with reading status
- Filter by status
- Show reading dates (started, reading, completed)
- Quick access to quiz and words

#### Navigation
- Link to Word Study
- Filter buttons for status
- Back to home button

### 7.2 User Flows

#### Access My Page Flow
1. User clicks username in header
2. My Page section displayed
3. Other sections hidden
4. Statistics loaded from API
5. All reading history loaded
6. Page scrolls to top

#### Filter Reading History Flow
1. User clicks status filter button (전체/시작/중/완료)
2. Active button highlighted
3. Book list filtered
4. Only matching books shown
5. If empty, empty state shown

#### Access Word Study Flow
1. User clicks "📖 단어 공부하기" button
2. Navigate to Word Study section
3. Word Study page initialized

### 7.3 UI Components

#### My Page Section
```html
- Header:
  - Title: "📚 내 독서 기록"
  - "홈으로" button (gray)

- Statistics Grid (4 cards):
  - Started count (yellow/orange gradient)
  - Reading count (teal gradient)
  - Completed count (green gradient)
  - Total count (blue gradient)

- Word Study Button:
  - "📖 단어 공부하기" (pink gradient, large)
  - Centered, prominent

- Filter Section:
  - Heading: "전체 독서 기록"
  - Filter buttons:
    - "전체" (default active)
    - "읽기 시작" (yellow)
    - "읽는 중" (teal)
    - "읽음" (green)

- Books Grid:
  - Book cards with full status info
  - Shows reading dates
  - Status badge on each card
  - Reading status buttons
  - Quiz and word buttons

- Empty State:
  - Icon: "📚"
  - Message: "아직 독서 기록이 없습니다."
  - Suggestion: "책을 검색하고 독서 상태를 추가해보세요!"
```

### 7.4 API Endpoints

```
GET /api/reading/stats
  Headers:
    - Authorization: Bearer <token>
  Response:
    {
      success: boolean,
      stats: {
        started_count: number,
        reading_count: number,
        completed_count: number,
        total_count: number
      }
    }

GET /api/reading/history
  Headers:
    - Authorization: Bearer <token>
  Query Parameters:
    - status: string (optional: started|reading|completed)
  Response:
    {
      success: boolean,
      data: [
        {
          isbn: string,
          title: string,
          author: string,
          series: string,
          bt_level: number,
          lexile: number,
          quiz: number,
          has_words: boolean,
          image_url: string,
          status: string,
          started_at: datetime,
          reading_at: datetime,
          completed_at: datetime
        }
      ]
    }
```

### 7.5 JavaScript Functions

```javascript
showMyPage()                    // Navigate to My Page
loadMyBooks(status)             // Load reading history
displayMyBooks(books)           // Render book cards
loadMyStats()                   // Load reading statistics
filterMyBooks(status)           // Filter by reading status
goToHome()                      // Navigate back to home
```

### 7.6 Global State

```javascript
currentFilter = 'all';          // Current status filter
myBooksData = [];               // All user's books
```

---

## 8. Words Panel (Modal)

### 8.1 Features

#### Word List Display
- Slide-in panel from right
- Shows all words for a specific book
- Word count in subtitle
- Scrollable list

### 8.2 User Flows

#### View Words Flow
1. User clicks "단어 보기" on book card
2. Slide panel opens from right
3. Loading state shown
4. Words loaded from API
5. Word list displayed
6. User can scroll through words
7. User clicks overlay or × to close

### 8.3 UI Components

#### Words Slide Panel
```html
- Overlay (semi-transparent black)
- Slide panel (600px wide, from right):
  - Header (purple gradient, sticky):
    - Title: "📚 단어 목록"
    - Subtitle: "총 X개의 단어" or ISBN
    - Close button (×)
  - Body (scrollable):
    - Loading state
    - Error state
    - Word items list
    - Empty state if no words
```

#### Word Item (in Panel)
```html
- Card layout:
  - Number badge (circular, purple)
  - Word (large, bold, dark)
  - Level badge: "📊 BT X.X / Lexile XXX"
  - Definition box (light gray bg):
    - "뜻:" label (purple, bold)
    - Korean definition
  - Example sentence box (light blue bg, blue border):
    - "예문:" label (teal, bold)
    - English sentence (italic)
```

### 8.4 API Endpoints

```
GET /api/books/:isbn/words
  Response:
    {
      success: boolean,
      data: {
        word_count: number,
        words: [
          {
            word: string,
            definition: string,
            example_sentence: string,
            min_bt_level: number,
            min_lexile: number
          }
        ]
      }
    }
```

### 8.5 JavaScript Functions

```javascript
loadWords(isbn)                 // Load words for a book
displayWords(data, isbn)        // Render word list
openSlidePanel(panelId)         // Open slide panel
closeSlidePanel()               // Close slide panel
```

---

## 9. API Endpoints Summary

### Authentication
```
GET  /api/auth/me              - Get current user info
POST /api/auth/logout          - Logout user
```

### Books
```
GET  /api/books/search         - Search books with filters
GET  /api/books/browse         - Browse books by filters only
GET  /api/books/filter-count   - Count books matching filters
GET  /api/books/search-count   - Count books matching search + filters
GET  /api/books/:isbn/quizzes  - Get quizzes for a book
GET  /api/books/:isbn/words    - Get words for a book
```

### Reading History
```
POST /api/reading/status       - Update reading status
GET  /api/reading/history      - Get reading history
GET  /api/reading/stats        - Get reading statistics
```

### Word Study
```
GET  /api/words/study          - Get words for study
POST /api/words/study/toggle   - Toggle word completion
GET  /api/words/quiz           - Generate word quiz
```

---

## 10. UI Components Summary

### Sections (Main Views)
1. **Search Section** - Book search and filters (always visible for guests)
2. **Reading Now Section** - Currently reading books (logged-in home)
3. **Results Section** - Search results display
4. **My Page Section** - Reading history and stats (logged-in only)
5. **Word Study Section** - Vocabulary learning (all users)
6. **Word Quiz Section** - Vocabulary testing (all users)

### Modals & Panels
1. **Words Slide Panel** - Book vocabulary (slide from right)
2. **Quiz Modal** - Book quizzes (centered overlay)

### Common Components
1. **Book Card** - Standard, with status, compact variants
2. **Filter Controls** - Dual-range sliders, buttons, toggles
3. **Status Buttons** - Started, Reading, Completed
4. **Action Buttons** - Quiz view, Word view
5. **Stat Cards** - Gradient cards for statistics

### UI Themes
- **Purple Gradient** - Primary actions, branding
- **Green Gradient** - Quizzes, correct answers, completed status
- **Pink Gradient** - Quiz modal, special actions
- **Yellow** - Started status
- **Teal** - Reading status
- **Red** - Incorrect answers, errors
- **Gray** - Secondary actions, disabled states

---

## 11. Navigation Flow

```
Home (Guest)
├── Search Section
│   ├── Search Results
│   │   ├── Quiz Modal
│   │   └── Words Panel
│   └── Word Study
│       └── Word Quiz
└── Login → Auth Page

Home (Logged In)
├── Reading Now Section
│   ├── Quiz Modal
│   └── Words Panel
├── Search Section
│   ├── Search Results
│   │   ├── Quiz Modal
│   │   ├── Words Panel
│   │   └── Status Update
│   └── Word Study
│       └── Word Quiz
└── My Page
    ├── Reading History
    │   ├── Quiz Modal
    │   ├── Words Panel
    │   └── Status Update
    ├── Statistics
    └── Word Study
        └── Word Quiz
```

---

## 12. State Management

### Global Variables
```javascript
currentUser = null;              // User object or null
currentFilter = 'all';           // My Page filter
myBooksData = [];                // User's books
currentGenre = 'all';            // Genre filter
currentQuizFilter = 'all';       // Quiz availability filter
currentLevelCondition = 'AND';   // Level filter condition

wordStudyData = {                // Word study state
  words: [],
  total: 0,
  currentOffset: 0,
  limit: 50,
  sortBy: 'bt_level',
  btLevel: 1.5,
  lexile: 300,
  tolerance: 0.2,
  completionFilter: 'all'
};

wordQuizData = {                 // Word quiz state
  quizzes: [],
  currentIndex: 0,
  correctCount: 0,
  answeredCount: 0,
  userAnswers: [],
  wrongQuestions: []
};
```

### LocalStorage
```javascript
localStorage.token     // JWT authentication token
localStorage.user      // User object JSON
```

---

## 13. Responsive Design

### Breakpoints
- **Mobile**: ≤ 480px
- **Tablet**: ≤ 768px
- **Desktop**: > 768px

### Mobile Adaptations
- Stack layout (single column)
- Smaller fonts and padding
- Stats section moved to bottom
- Toggle button to show/hide stats
- Horizontal scroll for reading now section
- Smaller book images
- Compact action buttons

---

## 14. Key Features by User Type

### Guest Users
✅ Search books
✅ View search results
✅ View quizzes
✅ View words
✅ Study vocabulary
✅ Take word quizzes
❌ Save reading status
❌ Track progress
❌ Mark words completed

### Logged-in Users
✅ All guest features
✅ Save reading status (started/reading/completed)
✅ View reading history
✅ View reading statistics
✅ See "Reading Now" section on home
✅ Mark words as completed
✅ Filter words by completion status
✅ Personalized dashboard (My Page)

---

## End of Specification

This comprehensive specification covers all functional features in the ReadingTurtle web application. Use this document for:
- Flutter migration planning
- Feature completeness checking
- API endpoint reference
- UI/UX design reference
- Testing checklist creation
