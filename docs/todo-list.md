# ReadingTurtle Flutter Migration - TODO List

## Document Information
- **Created**: 2025-10-19
- **Priority Levels**: 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low
- **Status**: ⬜ Not Started | 🔄 In Progress | ✅ Done

---

## Phase 1: Core User Features (High Priority)

### 1.1 Reading Status Management 🔴
**Goal**: Allow users to track their reading progress

- [ ] 🔴 **Backend API Endpoints** (if not exists)
  - [ ] POST `/api/reading/status` - Update book reading status
  - [ ] GET `/api/reading/history` - Get user's reading history
  - [ ] GET `/api/reading/stats` - Get reading statistics
  - [ ] Test endpoints with Postman/curl

- [ ] 🔴 **Reading Status Provider**
  - [ ] Create `reading_status_state.dart` with Freezed
  - [ ] Create `reading_status_provider.dart` with StateNotifier
  - [ ] Methods: `updateStatus(isbn, status)`, `loadHistory()`, `loadStats()`
  - [ ] Add to dependency injection

- [ ] 🔴 **Reading Status API Service**
  - [ ] Create `reading_status_api_service.dart`
  - [ ] Implement status update endpoint
  - [ ] Implement history fetch endpoint
  - [ ] Implement stats fetch endpoint
  - [ ] Error handling

- [ ] 🔴 **Status Buttons on Book Card**
  - [ ] Add status buttons row to `book_card.dart`
  - [ ] Three buttons: Started (yellow), Reading (teal), Completed (green)
  - [ ] Visual feedback for active status
  - [ ] Loading state during save
  - [ ] Integrate with provider

- [ ] 🟠 **Compact Book Card Variant**
  - [ ] Create `compact_book_card.dart` widget
  - [ ] Smaller layout for horizontal scroll
  - [ ] Compact status buttons
  - [ ] Quick quiz/words access

**Files to Create/Modify**:
- `lib/presentation/providers/reading_status_provider.dart` (new)
- `lib/presentation/providers/reading_status_state.dart` (new)
- `lib/data/api/reading_status_api_service.dart` (new)
- `lib/presentation/widgets/book_card.dart` (modify)
- `lib/presentation/widgets/compact_book_card.dart` (new)

---

### 1.2 My Page Implementation 🔴
**Goal**: User dashboard with reading history and statistics

- [ ] 🔴 **My Page Screen**
  - [ ] Create `my_page_screen.dart`
  - [ ] Header with "내 독서 기록" title
  - [ ] "홈으로" navigation button
  - [ ] Statistics grid section
  - [ ] Filter buttons (전체/시작/중/완료)
  - [ ] Reading history grid
  - [ ] Empty state handling
  - [ ] Loading/error states

- [ ] 🔴 **Statistics Cards**
  - [ ] Create `stat_card.dart` widget
  - [ ] Four cards: Started, Reading, Completed, Total
  - [ ] Gradient backgrounds (yellow, teal, green, blue)
  - [ ] Large number display
  - [ ] Stat labels
  - [ ] Responsive grid (2x2 on mobile, 1x4 on desktop)

- [ ] 🔴 **Book Card with Dates**
  - [ ] Extend `book_card.dart` or create variant
  - [ ] Show started_at, reading_at, completed_at
  - [ ] Date formatting (YYYY.MM.DD)
  - [ ] Conditional rendering based on status

- [ ] 🔴 **Filter Functionality**
  - [ ] Filter state management
  - [ ] Active button highlighting
  - [ ] Filter book list by status
  - [ ] Update displayed books

- [ ] 🔴 **Routing**
  - [ ] Add `/mypage` route to `router_config.dart`
  - [ ] Update navigation bar to link to My Page
  - [ ] Remove "coming soon" placeholder

- [ ] 🟠 **Word Study Button**
  - [ ] Large "📖 단어 공부하기" button
  - [ ] Pink gradient styling
  - [ ] Navigate to word study section

**Files to Create/Modify**:
- `lib/presentation/screens/mypage/my_page_screen.dart` (new)
- `lib/presentation/widgets/stat_card.dart` (new)
- `lib/presentation/widgets/book_card.dart` (modify)
- `lib/core/config/router_config.dart` (modify)
- `lib/presentation/widgets/app_navigation_bar.dart` (modify)

---

### 1.3 Level-Based Word Study 🔴
**Goal**: Independent word study with level selection

- [ ] 🔴 **Word Study Main Screen**
  - [ ] Create standalone `word_study_main_screen.dart`
  - [ ] Header: "📖 단어 공부하기"
  - [ ] "마이페이지로" button
  - [ ] Options panel (white card)
  - [ ] Progress stats panel
  - [ ] Word cards list
  - [ ] "더 보기" (load more) button

- [ ] 🔴 **Difficulty Criteria Selection**
  - [ ] Toggle buttons: BT Level / Lexile
  - [ ] Active state visual feedback
  - [ ] Switch between BT and Lexile sliders

- [ ] 🔴 **BT Level Selector**
  - [ ] Range slider 0-10 (step 0.1)
  - [ ] Current value display: "BT Level: X.X"
  - [ ] Guide text: "초급(0-3), 중급(3-7), 고급(7-10)"
  - [ ] Auto-load words on change

- [ ] 🔴 **Lexile Selector**
  - [ ] Range slider 0-1500 (step 50)
  - [ ] Current value display: "Lexile: XXX"
  - [ ] Guide text: "초급(0-500), 중급(500-800), 고급(800-1500)"
  - [ ] Auto-load words on change

- [ ] 🔴 **Word Study Provider**
  - [ ] Extend `word_provider.dart` or create new
  - [ ] State: words, total, offset, limit, sortBy, level, tolerance
  - [ ] Methods: `loadStudyWords()`, `loadMoreWords()`, `changeLevel()`
  - [ ] Pagination support (50 words per page)

- [ ] 🔴 **Word Study API**
  - [ ] Endpoint: GET `/api/words/study`
  - [ ] Query params: sortBy, btLevelMin, btLevelMax, lexileMin, lexileMax, limit, offset
  - [ ] Implement in `word_api_service.dart`

- [ ] 🟠 **Completion Filter** (logged-in only)
  - [ ] Toggle buttons: 전체 / 미완료 / 완료
  - [ ] Filter state management
  - [ ] API parameter: completionFilter

- [ ] 🟠 **Progress Stats Display**
  - [ ] Total words count
  - [ ] Current progress (X / Total)
  - [ ] Current sort criteria display

- [ ] 🟠 **Word Completion Tracking** (logged-in only)
  - [ ] "완료" button on each word card
  - [ ] API: POST `/api/words/study/toggle`
  - [ ] Update word list after toggle
  - [ ] Visual feedback (green background for completed)

- [ ] 🟠 **Link to Word Quiz**
  - [ ] "✍️ 단어 시험 보기" button (orange gradient)
  - [ ] Pass current level to quiz screen
  - [ ] Navigate to word quiz

**Files to Create/Modify**:
- `lib/presentation/screens/word_study/word_study_main_screen.dart` (new)
- `lib/presentation/providers/word_provider.dart` (modify)
- `lib/data/api/word_api_service.dart` (modify)
- `lib/core/config/router_config.dart` (modify)

---

### 1.4 Word Quiz System 🔴
**Goal**: Vocabulary testing with auto-generated quizzes

- [ ] 🔴 **Word Quiz Screen**
  - [ ] Create `word_quiz_screen.dart`
  - [ ] Header: "✍️ 단어 시험"
  - [ ] "단어 공부로" back button
  - [ ] Progress stats bar
  - [ ] Question card
  - [ ] Results screen

- [ ] 🔴 **Quiz Auto-Start**
  - [ ] Accept level parameters from word study
  - [ ] Auto-generate quiz on screen load
  - [ ] Default: 10 questions
  - [ ] Use studied level range

- [ ] 🔴 **Quiz Progress Display**
  - [ ] Progress stats bar (white card):
    - "진행: X / Y"
    - "정답: X / Y"
    - "정답률: X%"

- [ ] 🔴 **Question Card UI**
  - [ ] Question number
  - [ ] Level info badge (BT/Lexile)
  - [ ] Definition panel (light purple bg):
    - Korean definition
    - Example sentence (answer hidden as `_____`)
  - [ ] Instruction text
  - [ ] 4 word choice buttons (large, full width)

- [ ] 🔴 **Answer Selection Logic**
  - [ ] Select choice button
  - [ ] Highlight selected
  - [ ] Show correct answer (green)
  - [ ] Show wrong answer (red) if applicable
  - [ ] Disable all choices
  - [ ] 1.5s pause, then auto-advance
  - [ ] Update progress

- [ ] 🔴 **Quiz Results Screen**
  - [ ] Completion message: "🎉 시험 완료!"
  - [ ] Score display (large): "X / Y"
  - [ ] Accuracy: "정답률: X%"
  - [ ] Wrong answers list (yellow cards):
    - Question number
    - Definition
    - User's wrong answer (red)
    - Correct answer (green)
  - [ ] Action buttons

- [ ] 🔴 **Retry Wrong Answers**
  - [ ] "틀린 문제 다시 풀기" button (pink gradient)
  - [ ] Load only wrong questions
  - [ ] Restart quiz with filtered questions

- [ ] 🔴 **Word Quiz Provider**
  - [ ] Create `word_quiz_provider.dart`
  - [ ] Create `word_quiz_state.dart` with Freezed
  - [ ] State: quizzes, currentIndex, correctCount, userAnswers, wrongQuestions
  - [ ] Methods: `startQuiz()`, `answerQuestion()`, `retryWrong()`

- [ ] 🔴 **Word Quiz API**
  - [ ] Endpoint: GET `/api/words/quiz`
  - [ ] Query params: btLevelMin, btLevelMax, count
  - [ ] Implement in `word_api_service.dart`
  - [ ] Response: quiz questions with randomized choices

- [ ] 🟠 **Hide Answer in Example**
  - [ ] Helper function: `hideAnswerInSentence(sentence, answer)`
  - [ ] Replace answer word with `_____` in example

- [ ] 🟠 **New Quiz Button**
  - [ ] "새 시험 보기" button (purple gradient)
  - [ ] Reset state and start new quiz

**Files to Create/Modify**:
- `lib/presentation/screens/word_quiz/word_quiz_screen.dart` (new)
- `lib/presentation/providers/word_quiz_provider.dart` (new)
- `lib/presentation/providers/word_quiz_state.dart` (new)
- `lib/data/api/word_api_service.dart` (modify)
- `lib/core/config/router_config.dart` (modify)

---

### 1.5 Reading Now Section 🟠
**Goal**: Quick access to currently reading books on home screen

- [ ] 🟠 **Home Screen Enhancement**
  - [ ] Add "📖 읽는 중인 책" section to home screen
  - [ ] Only show when logged in and has reading books
  - [ ] Horizontal scroll layout
  - [ ] Load reading books on init

- [ ] 🟠 **Horizontal Scroll Grid**
  - [ ] Use `SingleChildScrollView` with horizontal axis
  - [ ] Display compact book cards
  - [ ] Scroll physics and padding

- [ ] 🟠 **Auto-Refresh**
  - [ ] Refresh when returning to home
  - [ ] Refresh after status update
  - [ ] Use Riverpod `ref.watch()` for reactivity

**Files to Modify**:
- `lib/presentation/screens/home/home_screen.dart`

---

## Phase 2: Enhanced Search & Filters (Medium Priority)

### 2.1 Advanced Search Types 🟡
**Goal**: Support all search types from original app

- [ ] 🟡 **Search Type Dropdown**
  - [ ] Add dropdown to search screen: All, ISBN, Title, Author, Series
  - [ ] Save selected type in state
  - [ ] Pass type to API call

- [ ] 🟡 **Backend Support**
  - [ ] Verify API supports `type` parameter
  - [ ] Update `book_api_service.dart` to include type

**Files to Modify**:
- `lib/presentation/screens/search/search_screen.dart`
- `lib/presentation/providers/book_provider.dart`

---

### 2.2 Lexile Filter 🟡
**Goal**: Add Lexile reading level filtering

- [ ] 🟡 **Lexile Range Slider**
  - [ ] Add slider to search screen (0-1500, step 50)
  - [ ] Display current range
  - [ ] Reset button

- [ ] 🟡 **Level Condition (AND/OR)**
  - [ ] Toggle buttons: AND / OR
  - [ ] Visual feedback for active condition
  - [ ] Pass to API

- [ ] 🟡 **Backend Integration**
  - [ ] Add lexileMin, lexileMax, levelCondition to API call
  - [ ] Update filter count API call

**Files to Modify**:
- `lib/presentation/screens/search/search_screen.dart`
- `lib/presentation/providers/book_provider.dart`
- `lib/data/api/book_api_service.dart`

---

### 2.3 Browse Without Query 🟡
**Goal**: Allow filtering without search query

- [ ] 🟡 **Browse Mode**
  - [ ] Enable search button when filters are set (even without query)
  - [ ] Show alert if > 500 books
  - [ ] Use `/api/books/browse` endpoint

- [ ] 🟡 **Browse API**
  - [ ] Implement browse endpoint in `book_api_service.dart`
  - [ ] Same filters as search, but no query required

**Files to Modify**:
- `lib/presentation/screens/search/search_screen.dart`
- `lib/data/api/book_api_service.dart`

---

### 2.4 Quiz Progress & Results 🟡
**Goal**: Track quiz performance within session

- [ ] 🟡 **Quiz Progress Indicator**
  - [ ] Add progress bar to quiz screen
  - [ ] Show current question number
  - [ ] Show correct/incorrect count
  - [ ] Show percentage

- [ ] 🟡 **Quiz Results Summary**
  - [ ] After last question, show results screen
  - [ ] Display final score
  - [ ] List wrong answers
  - [ ] Option to retry wrong questions
  - [ ] Option to restart quiz

**Files to Modify**:
- `lib/presentation/screens/quiz/quiz_screen.dart`
- `lib/presentation/providers/quiz_provider.dart`

---

## Phase 3: UI Polish & Optimization (Low Priority)

### 3.1 Dual-Range Slider Component 🟢
**Goal**: Proper min/max range selection

- [ ] 🟢 **Custom Range Slider Widget**
  - [ ] Create `dual_range_slider.dart`
  - [ ] Two handles for min and max
  - [ ] Visual progress bar
  - [ ] Value labels
  - [ ] Reset functionality

- [ ] 🟢 **Replace Existing Sliders**
  - [ ] Use in BT Level filter
  - [ ] Use in Lexile filter (when implemented)

**Files to Create/Modify**:
- `lib/presentation/widgets/dual_range_slider.dart` (new)
- `lib/presentation/screens/search/search_screen.dart` (modify)

---

### 3.2 Gradient Button Styling 🟢
**Goal**: Match original app's visual design

- [ ] 🟢 **Gradient Styles**
  - [ ] Purple gradient (primary): `#667eea` to `#764ba2`
  - [ ] Green gradient (quiz): `#4facfe` to `#00f2fe`
  - [ ] Pink gradient (special): TBD
  - [ ] Orange gradient (word quiz): TBD

- [ ] 🟢 **Apply to Components**
  - [ ] Search button
  - [ ] Quiz button
  - [ ] Word quiz button
  - [ ] Action buttons

**Files to Modify**:
- Multiple widget files

---

### 3.3 Additional Book Info Display 🟢
**Goal**: Show ISBN and Series on book cards

- [ ] 🟢 **Book Card Enhancement**
  - [ ] Add ISBN badge (purple gradient, top-left)
  - [ ] Add Series field to info grid
  - [ ] Responsive layout adjustment

**Files to Modify**:
- `lib/presentation/widgets/book_card.dart`

---

### 3.4 Mobile Optimizations 🟢
**Goal**: Better mobile experience

- [ ] 🟢 **Stats Toggle Button**
  - [ ] Add toggle button for stats section on mobile
  - [ ] Show/hide animation
  - [ ] Remember state

- [ ] 🟢 **Compact Navigation**
  - [ ] Smaller fonts and padding on mobile
  - [ ] Responsive header layout

**Files to Modify**:
- Various screen files

---

## Phase 4: Testing & Quality Assurance

### 4.1 Unit Tests 🟡
- [ ] 🟡 Test providers (auth, book, quiz, word, reading status)
- [ ] 🟡 Test API services
- [ ] 🟡 Test utility functions
- [ ] 🟡 Test state classes

### 4.2 Widget Tests 🟡
- [ ] 🟡 Test book card rendering
- [ ] 🟡 Test quiz item widget
- [ ] 🟡 Test word card widget
- [ ] 🟡 Test search screen
- [ ] 🟡 Test my page screen

### 4.3 Integration Tests 🟡
- [ ] 🟡 Test complete search flow
- [ ] 🟡 Test quiz completion flow
- [ ] 🟡 Test word study flow
- [ ] 🟡 Test authentication flow

---

## Phase 5: Advanced Features (Future)

### 5.1 Offline Support 🟢
- [ ] 🟢 Cache book data locally
- [ ] 🟢 Offline quiz access
- [ ] 🟢 Sync when online

### 5.2 Performance 🟢
- [ ] 🟢 Image optimization
- [ ] 🟢 Lazy loading
- [ ] 🟢 List virtualization

### 5.3 Analytics 🟢
- [ ] 🟢 Track user actions
- [ ] 🟢 Reading analytics
- [ ] 🟢 Quiz performance metrics

---

## Summary

| Phase | Tasks | Priority | Estimated Effort |
|-------|-------|----------|------------------|
| Phase 1 | 5 features | 🔴 Critical | 3-4 weeks |
| Phase 2 | 4 features | 🟡 Medium | 1-2 weeks |
| Phase 3 | 4 features | 🟢 Low | 1 week |
| Phase 4 | Testing | 🟡 Medium | 2 weeks |
| Phase 5 | Advanced | 🟢 Future | TBD |

**Total Estimated Time**: 7-9 weeks for Phases 1-4

---

## Development Priorities

1. **Week 1-2**: Reading status management + My Page
2. **Week 3-4**: Level-based word study + Word quiz
3. **Week 5**: Reading Now section + Advanced search
4. **Week 6**: Lexile filter + Browse mode
5. **Week 7-8**: UI polish + Testing
6. **Week 9**: Buffer/refinement

---

## End of TODO List

**Next Action**: Start with Phase 1.1 - Reading Status Management
