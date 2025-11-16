# Interactive Tutorial Implementation Guide

**Date**: 2025-10-24
**Status**: Core widget created, integration pending

---

## ✅ What's Been Created

### 1. Interactive Tutorial Overlay Widget
- **Location**: `flutter/lib/presentation/widgets/interactive_tutorial_overlay.dart`
- **Features**:
  - Semi-transparent overlay with spotlight on target elements
  - Animated arrows pointing to UI elements
  - Tutorial cards with title and description
  - Previous/Next/Skip buttons
  - Progress indicator (e.g., "1 / 5")
  - Smooth fade and scale animations

### 2. Tutorial Step Model
```dart
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;  // Widget to highlight
  final TutorialPosition position;  // Arrow position
}
```

### 3. Storage Keys
- Added `hasSeenInteractiveTutorial` to `StorageKeys`
- Separate from `hasSeenOnboarding` for dual tutorial system

---

## 🎯 How It Works

### Visual Design
1. **Dark Overlay**: 70% black overlay covers entire screen
2. **Spotlight**: Circular/rounded rect hole cuts out target widget
3. **Green Border**: 3px green border around highlighted element
4. **Arrow**: White arrow pointing to target (auto-positioned)
5. **Tutorial Card**: White card with title, description, and buttons
6. **Auto-positioning**: Card appears above or below target based on screen position

### User Flow
```
Home Screen First Visit
  ↓
Check hasSeenInteractiveTutorial?
  ├─ No → Show Interactive Tutorial
  │   ↓
  │   Step 1: Search Button
  │   Step 2: Filter Icon
  │   Step 3: Book Card (Quiz Button)
  │   Step 4: Book Card (Words Button)
  │   Step 5: Navigation Bar
  │   ↓
  │   Mark as completed
  └─ Yes → Normal home screen
```

---

## 📋 Implementation Steps (TODO)

### Step 1: Add GlobalKeys to Target Widgets

Edit `scaffold_with_nav_bar.dart` to add keys:

```dart
class ScaffoldWithNavBar extends StatelessWidget {
  // Add these keys
  static final GlobalKey searchTabKey = GlobalKey();
  static final GlobalKey mypageTabKey = GlobalKey();

  // In NavigationBar items:
  NavigationDestination(
    key: searchTabKey,  // Add this
    icon: Icon(Icons.search),
    label: 'Search',
  ),
```

### Step 2: Add Keys to Home Screen

Edit `home_screen.dart`:

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Add keys
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _calendarButtonKey = GlobalKey();

  // Modify widgets:
  ElevatedButton.icon(
    key: _searchButtonKey,  // Add this
    onPressed: () => context.go('/search'),
    // ...
  )
```

### Step 3: Add Keys to Search Screen

Edit `search_screen.dart`:

```dart
final GlobalKey _filterButtonKey = GlobalKey();

IconButton(
  key: _filterButtonKey,
  icon: Icon(Icons.filter_list),
  // ...
)
```

### Step 4: Add Keys to Book Card

Edit `book_card.dart`:

```dart
class BookCard extends StatelessWidget {
  static final GlobalKey quizButtonKey = GlobalKey();
  static final GlobalKey wordsButtonKey = GlobalKey();

  // In quiz button:
  ElevatedButton.icon(
    key: quizButtonKey,
    icon: Icon(Icons.quiz),
    // ...
  )
```

### Step 5: Create Tutorial Provider

Create `interactive_tutorial_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/storage_service.dart';
import '../providers/auth_provider.dart';

final interactiveTutorialProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getBool(StorageKeys.hasSeenInteractiveTutorial) ?? false;
});
```

### Step 6: Integrate into Home Screen

Add to `home_screen.dart`:

```dart
import '../widgets/interactive_tutorial_overlay.dart';

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storageService = ref.read(storageServiceProvider);
      final hasSeenTutorial = await storageService.getBool(
        StorageKeys.hasSeenInteractiveTutorial
      ) ?? false;

      if (!hasSeenTutorial && mounted) {
        setState(() {
          _showTutorial = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original content
        SingleChildScrollView(...),

        // Tutorial overlay
        if (_showTutorial)
          InteractiveTutorialOverlay(
            steps: _getTutorialSteps(),
            onComplete: () async {
              final storageService = ref.read(storageServiceProvider);
              await storageService.setBool(
                StorageKeys.hasSeenInteractiveTutorial,
                true,
              );
              setState(() {
                _showTutorial = false;
              });
            },
            onSkip: () async {
              final storageService = ref.read(storageServiceProvider);
              await storageService.setBool(
                StorageKeys.hasSeenInteractiveTutorial,
                true,
              );
              setState(() {
                _showTutorial = false;
              });
            },
          ),
      ],
    );
  }

  List<TutorialStep> _getTutorialSteps() {
    return [
      TutorialStep(
        title: '도서 검색',
        description: '여기를 클릭하여 121,000권 이상의 영어 도서를 검색할 수 있습니다. 레벨, 장르, 퀴즈 여부 등으로 필터링할 수 있어요!',
        targetKey: _searchButtonKey,
        position: TutorialPosition.bottom,
      ),
      TutorialStep(
        title: '독서 캘린더',
        description: '매일의 독서 기록을 캘린더에 저장하고 관리하세요. 독서 습관을 만들어가는 데 도움이 됩니다!',
        targetKey: _calendarButtonKey,
        position: TutorialPosition.bottom,
      ),
      // Add more steps...
    ];
  }
}
```

---

## 🎨 Tutorial Steps to Implement

### Step 1: Search Button
- **Title**: "도서 검색"
- **Description**: "여기를 클릭하여 121,000권 이상의 영어 도서를 검색할 수 있습니다."
- **Target**: Home screen search button

### Step 2: Filter Button
- **Title**: "검색 필터"
- **Description**: "BT 레벨, Lexile 지수, 장르별로 책을 필터링할 수 있습니다."
- **Target**: Search screen filter icon

### Step 3: Quiz Button
- **Title**: "퀴즈 풀기"
- **Description**: "책의 퀴즈 버튼을 클릭하면 독해력 퀴즈를 풀 수 있어요!"
- **Target**: Book card quiz button

### Step 4: Words Button
- **Title**: "단어 학습"
- **Description**: "책에 나오는 중요 단어들을 학습하고 북마크할 수 있습니다."
- **Target**: Book card words button

### Step 5: Navigation Bar
- **Title**: "네비게이션"
- **Description**: "하단 네비게이션 바로 검색, 마이페이지를 쉽게 이동할 수 있어요."
- **Target**: Bottom navigation bar

---

## 🔧 Advanced Features (Optional)

### 1. Context-Aware Tutorials
Show different tutorials based on user state:

```dart
List<TutorialStep> _getTutorialSteps() {
  final authState = ref.read(authProvider);
  final isAuthenticated = authState.user != null;

  if (isAuthenticated) {
    return _getAuthenticatedUserSteps();
  } else {
    return _getGuestUserSteps();
  }
}
```

### 2. Multi-Screen Tutorials
Navigate between screens during tutorial:

```dart
TutorialStep(
  title: '검색 화면으로 이동',
  description: '이제 검색 화면으로 이동합니다...',
  targetKey: _searchButtonKey,
  onComplete: () {
    context.go('/search');
    // Continue tutorial on search screen
  },
)
```

### 3. Interactive Elements
Allow users to actually click buttons during tutorial:

```dart
// In tutorial overlay, add tap-through mode
GestureDetector(
  onTapUp: (details) {
    if (_isInsideTarget(details.globalPosition, targetRect)) {
      // Allow interaction with target
      _handleTargetInteraction();
    }
  },
  // ...
)
```

### 4. Tutorial Replay
Add button in settings to replay tutorial:

```dart
// In MyPageScreen:
ListTile(
  leading: Icon(Icons.help_outline),
  title: Text('튜토리얼 다시 보기'),
  onTap: () async {
    final storageService = ref.read(storageServiceProvider);
    await storageService.setBool(
      StorageKeys.hasSeenInteractiveTutorial,
      false,
    );
    context.go('/');
  },
)
```

---

## 🧪 Testing Checklist

- [ ] Tutorial shows on first home screen visit
- [ ] Spotlight correctly highlights each target widget
- [ ] Arrow points to correct position
- [ ] Card appears above/below target appropriately
- [ ] "Previous" button works (except on first step)
- [ ] "Next" button advances through steps
- [ ] "Skip" button closes tutorial and marks as complete
- [ ] "Complete" button on last step closes tutorial
- [ ] Tutorial doesn't show again after completion
- [ ] Animations are smooth and pleasant
- [ ] Works on different screen sizes
- [ ] Can be replayed from settings (if implemented)

---

## 📱 Responsive Design

### Mobile (<600px)
- Full-width tutorial cards
- Larger arrow size (48px)
- More padding around hole

### Tablet (600-900px)
- Centered tutorial cards with max-width
- Standard arrow size (40px)

### Desktop (>900px)
- Positioned tutorial cards next to target
- Smaller arrow size (32px)
- Can show multiple highlights simultaneously (advanced)

---

## 🎯 Key Differences from Onboarding

| Feature | Static Onboarding | Interactive Tutorial |
|---------|-------------------|---------------------|
| **When** | After splash, before app | On home screen first visit |
| **Content** | Overview of features | Specific UI element guidance |
| **Interaction** | Swipe through pages | Follow arrows, actual UI |
| **Skippable** | Yes | Yes |
| **Replay** | Hard to trigger | Easy from settings |
| **Storage Key** | `hasSeenOnboarding` | `hasSeenInteractiveTutorial` |

---

## 🚀 Quick Start Implementation

### Minimal Example

```dart
// 1. Add to home_screen.dart
import '../widgets/interactive_tutorial_overlay.dart';

// 2. Add state
bool _showTutorial = false;
final GlobalKey _searchKey = GlobalKey();

// 3. Wrap in Stack
Stack(
  children: [
    // Original content
    YourHomeScreenContent(searchKey: _searchKey),

    // Tutorial
    if (_showTutorial)
      InteractiveTutorialOverlay(
        steps: [
          TutorialStep(
            title: '검색하기',
            description: '여기를 눌러 책을 검색하세요',
            targetKey: _searchKey,
          ),
        ],
        onComplete: () {
          setState(() => _showTutorial = false);
        },
      ),
  ],
)
```

---

## 📝 Next Steps

1. **Complete GlobalKey Assignment**
   - Add keys to all tutorial target widgets
   - Test key references are not null

2. **Implement Provider**
   - Create interactive_tutorial_provider.dart
   - Integrate with storage service

3. **Add to Home Screen**
   - Implement tutorial state management
   - Define tutorial steps
   - Test full flow

4. **Polish**
   - Adjust arrow positioning
   - Fine-tune animations
   - Add haptic feedback (mobile)
   - Test on various screen sizes

5. **Documentation**
   - Add tutorial replay button
   - Update user guide
   - Create video walkthrough

---

## 🎉 Benefits

1. **Better User Onboarding**: Users see exactly where to click
2. **Reduced Support Tickets**: Clear guidance reduces confusion
3. **Higher Engagement**: Interactive tutorials are more engaging
4. **Flexible**: Can add/remove steps easily
5. **Reusable**: Component can be used on any screen

---

## 🔗 Related Files

- `flutter/lib/presentation/widgets/interactive_tutorial_overlay.dart` (Created)
- `flutter/lib/core/constants/storage_keys.dart` (Updated)
- `flutter/lib/presentation/screens/home/home_screen.dart` (To be updated)
- `flutter/lib/presentation/widgets/scaffold_with_nav_bar.dart` (To be updated)
- `flutter/lib/presentation/screens/search/search_screen.dart` (To be updated)
- `flutter/lib/presentation/widgets/book_card.dart` (To be updated)

**Last Updated**: 2025-10-24
