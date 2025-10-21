# Daily Quiz - Persistence & State Management Analysis

## Current Implementation Overview

The Daily Quiz uses a **day-of-year rotation system** to pick different quizzes each day, but has **NO state persistence or completion tracking**.

---

## Problem Scenarios

### Scenario 1: User Solves 1 Question, Closes App

**What Happens**:

```
User opens quiz:
  ├─> QuizViewModel.init() creates NEW instance
  ├─> Loads quizzes from JSON
  ├─> Picks quiz of day
  ├─> Sets currentIndex = 0  ← Always starts at question 1
  ├─> Sets score = 0         ← Always resets to 0
  └─> Shows first question

User answers Question 1 (correct):
  ├─> score = 1
  ├─> currentIndex = 0
  └─> User closes app (taps X or swipes down)

User reopens quiz later:
  ├─> QuizViewModel.init() called AGAIN
  ├─> Everything resets!
  ├─> currentIndex = 0  ← Back to question 1
  ├─> score = 0         ← Progress lost!
  └─> Shows Question 1 again (not Question 2)
```

**Result**: ❌ **All progress lost. Must start over from question 1.**

---

### Scenario 2: User Completes Quiz

**What Happens**:

```
User answers all questions:
  ├─> Last question answered
  ├─> Taps "See Results"
  └─> QuizResultView shows:
      ├─> Score: 2/2
      ├─> Grade: "Excellent 🌟"
      └─> [Retry] [Share] [Done] buttons

User taps [Done]:
  └─> Dismisses QuizResultView
      └─> Dismisses QuizView
          └─> Returns to TodayView

User taps "Daily Quiz" button again:
  ├─> QuizView opens FRESH
  ├─> QuizViewModel.init() creates NEW instance
  ├─> Everything resets!
  └─> Same quiz appears (same day, same questions)

User can retake quiz unlimited times!
```

**Result**: ❌ **No completion tracking. Can retake infinitely on same day.**

---

## What's Missing

### 1. No State Persistence

Currently **NOT saved**:
- ❌ Current question index (which question user is on)
- ❌ Current score (how many correct so far)
- ❌ User's answers (what they selected for each question)
- ❌ Completion status (did they finish?)
- ❌ Completion timestamp (when did they finish?)

### 2. No Completion Tracking

No record of:
- ❌ Did user complete today's quiz?
- ❌ What was their score?
- ❌ When did they complete it?
- ❌ Can they retake or is it locked?

### 3. No Resume Functionality

Can't:
- ❌ Resume from where you left off
- ❌ See "Continue Quiz" vs "Start Quiz" button
- ❌ Prevent accidentally starting over
- ❌ Show progress indicator in TodayView

---

## Current Code Analysis

### QuizViewModel Initialization (Lines 38-49)

```swift
init(quizzes: [QuizModel]? = nil, preselected quiz: QuizModel? = nil) {
    // Load quizzes from JSON file or use provided quizzes
    let resolvedQuizzes = quizzes ?? QuizViewModel.loadQuizzesFromJSON()
    let resolvedQuizOfDay = quiz ?? QuizViewModel.pickQuizOfDay(from: resolvedQuizzes)

    // Load Quran data for verse fetching
    self.quranSurahs = QuranService.shared.loadQuran(language: .english)

    // now assign to self
    self.quizzes = resolvedQuizzes
    self.quizOfDay = resolvedQuizOfDay
}
```

**Issues**:
- No check for existing progress
- Always starts with `currentIndex = 0`, `score = 0`
- No date-based completion check
- Creates fresh state every time

### State Properties (Lines 7-13)

```swift
// State
@Published private(set) var currentIndex: Int = 0
@Published private(set) var selectedIndex: Int? = nil
@Published private(set) var isLocked: Bool = false
@Published private(set) var score: Int = 0

@Published var didFinish: Bool = false
```

**Issues**:
- All hardcoded to initial values
- No loading from storage
- State exists only in memory
- Lost when ViewModel deallocates

---

## How Other Apps Handle This

### Option A: Session-Based (During Quiz Only)

**While quiz is open**:
- ✅ Save progress after each question
- ✅ If app backgrounded → Save state
- ✅ If app reopened → Resume from saved state

**After completing/closing**:
- ✅ Clear progress
- ✅ Allow retake from start

**Pros**:
- Simple implementation
- No completion restrictions
- Good for practice/learning mode

**Cons**:
- Can retake unlimited times
- No "daily" enforcement
- No streak tracking

---

### Option B: Daily Completion (Once Per Day)

**Once completed**:
- ✅ Mark today's quiz as DONE
- ✅ Show "Quiz completed ✓" message
- ✅ Don't allow retaking until tomorrow
- ✅ Track score in history

**If not completed**:
- ✅ Allow resuming from last question
- ✅ Save progress continuously

**Pros**:
- Enforces "daily" concept
- Prevents gaming the system
- Enables streak tracking
- Motivates daily engagement

**Cons**:
- User can't practice old quizzes
- Missed day = broken streak
- More complex logic

---

### Option C: Hybrid (Best User Experience)

**In Progress**:
- ✅ Save after each question
- ✅ Allow resume if interrupted
- ✅ Show "Continue Quiz (2/5)" button

**Completed**:
- ✅ Mark as done for the day
- ✅ Show result badge on TodayView
- ✅ Allow ONE retry per day (optional)
- ✅ Tomorrow → New quiz unlocks

**After Midnight**:
- ✅ New quiz available
- ✅ Old progress archived to history
- ✅ Streak continues if completed

**Pros**:
- Best of both worlds
- Great UX (no lost progress)
- Enforces daily habit
- Flexible (allows retry)

**Cons**:
- Most complex to implement
- Need careful date handling
- Need history/archive system

---

## Recommended Solution: Hybrid Approach

### User Experience Flow

```
═══════════════════════════════════════════════════════════
FIRST TIME TODAY (No Progress)
═══════════════════════════════════════════════════════════
TodayView shows:
  ┌─────────────────────────────────┐
  │  📝 Daily Quiz                  │
  │  Test your Islamic knowledge    │
  │                    [Start Quiz] │
  └─────────────────────────────────┘

User taps [Start Quiz]:
  └─> QuizView opens
      └─> Shows Question 1

═══════════════════════════════════════════════════════════
DURING QUIZ (Progress Exists)
═══════════════════════════════════════════════════════════
User answers Question 1:
  ├─> Auto-saves: currentIndex=0, score=1
  └─> User closes app (backgrounded/quit)

User reopens app:
TodayView shows:
  ┌─────────────────────────────────┐
  │  📝 Daily Quiz                  │
  │  Continue where you left off    │
  │           [Continue Quiz (2/5)] │
  └─────────────────────────────────┘

User taps [Continue Quiz]:
  └─> QuizView opens
      └─> Resumes at Question 2 (not Question 1!)

═══════════════════════════════════════════════════════════
COMPLETED TODAY
═══════════════════════════════════════════════════════════
User finishes all questions:
  ├─> See results: "Excellent 🌟 4/5"
  ├─> Auto-saves: isCompleted=true, score=4
  └─> Dismisses quiz

TodayView shows:
  ┌─────────────────────────────────┐
  │  ✅ Daily Quiz Completed        │
  │  Score: 4/5 (80%)               │
  │  🔥 5 day streak!               │
  │                      [View] [↻] │
  └─────────────────────────────────┘

[View] → Shows QuizResultView (read-only)
[↻]    → Retries same quiz (resets progress)

═══════════════════════════════════════════════════════════
NEXT DAY (New Quiz Available)
═══════════════════════════════════════════════════════════
TodayView shows:
  ┌─────────────────────────────────┐
  │  📝 Daily Quiz                  │
  │  New quiz available!            │
  │                    [Start Quiz] │
  └─────────────────────────────────┘

Yesterday's quiz archived to history
Fresh quiz loaded (new questions)
```

---

## Implementation Guide

### Phase 1: Data Model

**New File**: Create `QuizProgress` model

```swift
//
//  QuizProgress.swift
//  Deen Buddy Advanced
//
//  Tracks daily quiz progress and completion
//

import Foundation

struct QuizProgress: Codable {
    let date: String              // "20251021" (YYYYMMDD)
    let quizTitle: String          // "Quran Basics"
    var currentIndex: Int          // 0, 1, 2, 3, 4 (which question)
    var score: Int                 // Number of correct answers so far
    var userAnswers: [Int?]        // User's selected answer indices
    var isCompleted: Bool          // Has user finished all questions?
    var completedAt: Date?         // When did they complete it?
    var finalScore: Int?           // Final score (only set when completed)

    init(date: String, quizTitle: String, totalQuestions: Int) {
        self.date = date
        self.quizTitle = quizTitle
        self.currentIndex = 0
        self.score = 0
        self.userAnswers = Array(repeating: nil, count: totalQuestions)
        self.isCompleted = false
        self.completedAt = nil
        self.finalScore = nil
    }
}
```

---

### Phase 2: Update QuizViewModel

#### Add Properties

```swift
// Add to QuizViewModel (after line 13)
private var currentProgress: QuizProgress?

// Computed properties
var hasProgress: Bool {
    currentProgress != nil && !currentProgress!.isCompleted
}

var isCompletedToday: Bool {
    currentProgress?.isCompleted ?? false
}

private var todayYMD: String {
    DateFormatter.yyyyMMdd.string(from: Date())
}

private var progressKey: String {
    "quizProgress.\(todayYMD)"
}
```

#### Update Init

```swift
init(quizzes: [QuizModel]? = nil, preselected quiz: QuizModel? = nil) {
    // ... existing code ...

    // Load today's progress (if any)
    loadProgress()
}
```

#### Add Load/Save Functions

```swift
// MARK: - Progress Persistence

private func loadProgress() {
    let key = progressKey

    guard let data = UserDefaults.standard.data(forKey: key),
          let progress = try? JSONDecoder().decode(QuizProgress.self, from: data) else {
        // No saved progress for today
        currentProgress = nil
        return
    }

    // Check if progress is for current quiz
    guard progress.quizTitle == quizOfDay.title else {
        // Different quiz (day changed or quiz changed)
        clearProgress()
        return
    }

    // Restore state from saved progress
    currentProgress = progress
    self.currentIndex = progress.currentIndex
    self.score = progress.score
    self.didFinish = progress.isCompleted

    print("✅ Restored progress: Question \(progress.currentIndex + 1)/\(totalQuestions), Score: \(progress.score)")
}

private func saveProgress() {
    let key = progressKey

    // Create or update progress
    if currentProgress == nil {
        currentProgress = QuizProgress(
            date: todayYMD,
            quizTitle: quizOfDay.title,
            totalQuestions: totalQuestions
        )
    }

    // Update current state
    currentProgress?.currentIndex = currentIndex
    currentProgress?.score = score
    currentProgress?.isCompleted = didFinish

    if let index = selectedIndex {
        currentProgress?.userAnswers[currentIndex] = index
    }

    if didFinish {
        currentProgress?.completedAt = Date()
        currentProgress?.finalScore = score
    }

    // Save to UserDefaults
    if let data = try? JSONEncoder().encode(currentProgress) {
        UserDefaults.standard.set(data, forKey: key)
        print("💾 Saved progress: Question \(currentIndex + 1)/\(totalQuestions), Score: \(score)")
    }
}

private func clearProgress() {
    let key = progressKey
    UserDefaults.standard.removeObject(forKey: key)
    currentProgress = nil
    print("🗑️ Cleared quiz progress")
}
```

#### Update Existing Functions

```swift
// Update selectAnswer to save progress
func selectAnswer(_ index: Int) {
    guard !isLocked, quizOfDay.questions.indices.contains(currentIndex) else { return }
    selectedIndex = index
    isLocked = true
    if index == currentQuestion.correctIndex { score += 1 }

    // ⬅️ ADD THIS
    saveProgress()
}

// Update next to save progress
func next() {
    guard isLocked else { return }
    if isLastQuestion {
        finish()
        return
    }
    currentIndex += 1
    selectedIndex = nil
    isLocked = false

    // ⬅️ ADD THIS
    saveProgress()
}

// Update finish to save completion
func finish() {
    didFinish = true

    // ⬅️ ADD THIS
    saveProgress()
}

// Update restartSameQuiz to clear progress
func restartSameQuiz() {
    currentIndex = 0
    selectedIndex = nil
    isLocked = false
    score = 0
    didFinish = false

    // ⬅️ ADD THIS
    clearProgress()
}
```

---

### Phase 3: Update TodayView

#### Current Code (Lines 27-42)

```swift
// Daily Quiz Button
Button(action: {
    showQuiz = true
}) {
    HStack {
        Image(systemName: "questionmark.circle.fill")
        Text(AppStrings.today.dailyQuiz)
            .fontWeight(.semibold)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(AppColors.Today.dailyQuizButton)
    .foregroundColor(AppColors.Today.dailyQuizText)
    .cornerRadius(12)
}
.padding(.horizontal)
```

#### Updated Code (with Progress Awareness)

```swift
// Daily Quiz Button (with progress/completion awareness)
DailyQuizButton(
    isCompleted: quizVM.isCompletedToday,
    hasProgress: quizVM.hasProgress,
    currentQuestion: quizVM.currentIndex + 1,
    totalQuestions: quizVM.totalQuestions,
    score: quizVM.score
) {
    showQuiz = true
}
.padding(.horizontal)

// Add this @StateObject at top of TodayView
@StateObject private var quizVM = QuizViewModel()
```

#### Create DailyQuizButton Component

**New File**: `/Views/TodayView/DailyQuizButton.swift`

```swift
//
//  DailyQuizButton.swift
//  Deen Buddy Advanced
//
//  Smart button that shows different states for daily quiz
//

import SwiftUI

struct DailyQuizButton: View {
    let isCompleted: Bool
    let hasProgress: Bool
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20))

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(titleText)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if let subtitle = subtitleText {
                        Text(subtitle)
                            .font(.caption)
                            .opacity(0.9)
                    }
                }

                Spacer()

                // Arrow or checkmark
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
        }
        .disabled(isCompleted && !hasProgress)
    }

    // MARK: - Computed Properties

    private var iconName: String {
        if isCompleted {
            return "checkmark.circle.fill"
        } else if hasProgress {
            return "play.circle.fill"
        } else {
            return "questionmark.circle.fill"
        }
    }

    private var titleText: String {
        if isCompleted {
            return "Quiz Completed ✓"
        } else if hasProgress {
            return "Continue Quiz"
        } else {
            return AppStrings.today.dailyQuiz
        }
    }

    private var subtitleText: String? {
        if isCompleted {
            return "Score: \(score)/\(totalQuestions) (\(percentageText))"
        } else if hasProgress {
            return "Question \(currentQuestion)/\(totalQuestions)"
        } else {
            return "Test your Islamic knowledge"
        }
    }

    private var backgroundColor: Color {
        if isCompleted {
            return AppColors.Common.green.opacity(0.15)
        } else {
            return AppColors.Today.dailyQuizButton
        }
    }

    private var textColor: Color {
        if isCompleted {
            return AppColors.Common.green
        } else {
            return AppColors.Today.dailyQuizText
        }
    }

    private var percentageText: String {
        let pct = Double(score) / Double(totalQuestions) * 100
        return String(format: "%.0f%%", pct)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Not started
        DailyQuizButton(
            isCompleted: false,
            hasProgress: false,
            currentQuestion: 1,
            totalQuestions: 5,
            score: 0
        ) {}

        // In progress
        DailyQuizButton(
            isCompleted: false,
            hasProgress: true,
            currentQuestion: 3,
            totalQuestions: 5,
            score: 2
        ) {}

        // Completed
        DailyQuizButton(
            isCompleted: true,
            hasProgress: false,
            currentQuestion: 5,
            totalQuestions: 5,
            score: 4
        ) {}
    }
    .padding()
}
```

---

### Phase 4: Add Strings

**Update**: `/Utilities/Strings/TodayStrings.swift`

```swift
// Add to existing TodayStrings struct
struct TodayStrings {
    // ... existing strings ...

    // Daily Quiz Progress
    static let continueQuiz = "Continue Quiz"
    static let quizCompleted = "Quiz Completed ✓"
    static let questionProgress = "Question %d/%d"
    static let testKnowledge = "Test your Islamic knowledge"
}
```

---

### Phase 5: Optional - Add History Tracking

**New Model**: `QuizHistory.swift`

```swift
//
//  QuizHistory.swift
//  Deen Buddy Advanced
//
//  Historical record of completed quizzes
//

import Foundation

struct QuizHistoryEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let quizTitle: String
    let score: Int
    let totalQuestions: Int
    let percentage: Double
    let completedAt: Date

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

class QuizHistoryStore {
    private let key = "quizHistory"

    func save(entry: QuizHistoryEntry) {
        var history = loadAll()
        history.append(entry)

        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadAll() -> [QuizHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let history = try? JSONDecoder().decode([QuizHistoryEntry].self, from: data) else {
            return []
        }
        return history.sorted { $0.date > $1.date } // Most recent first
    }

    func getLast7Days() -> [QuizHistoryEntry] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return loadAll().filter { $0.date >= sevenDaysAgo }
    }

    func getCurrentStreak() -> Int {
        let history = loadAll()
        var streak = 0
        var checkDate = Date()

        while true {
            let hasEntry = history.contains { Calendar.current.isDate($0.date, inSameDayAs: checkDate) }
            if hasEntry {
                streak += 1
            } else {
                break
            }

            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }
}
```

**Save to History When Quiz Completes**:

```swift
// In QuizViewModel.finish()
func finish() {
    didFinish = true
    saveProgress()

    // ⬅️ ADD THIS
    saveToHistory()
}

private func saveToHistory() {
    let entry = QuizHistoryEntry(
        id: UUID(),
        date: Date(),
        quizTitle: quizOfDay.title,
        score: score,
        totalQuestions: totalQuestions,
        percentage: percent,
        completedAt: Date()
    )

    QuizHistoryStore().save(entry: entry)
    print("📊 Saved to history: \(score)/\(totalQuestions)")
}
```

---

## Implementation Checklist

### Phase 1: Basic Persistence ✓
- [ ] Create `QuizProgress` model
- [ ] Add `loadProgress()` function to QuizViewModel
- [ ] Add `saveProgress()` function to QuizViewModel
- [ ] Call `saveProgress()` in `selectAnswer()`
- [ ] Call `saveProgress()` in `next()`
- [ ] Call `saveProgress()` in `finish()`
- [ ] Test: Answer 1 question, close app, reopen → Should resume

### Phase 2: UI Updates ✓
- [ ] Create `DailyQuizButton` component
- [ ] Add completion state display
- [ ] Add progress state display ("Continue Quiz 2/5")
- [ ] Update TodayView to use smart button
- [ ] Add strings to TodayStrings
- [ ] Test: Button shows correct state based on progress

### Phase 3: Completion Tracking ✓
- [ ] Add `isCompletedToday` computed property
- [ ] Disable button when completed
- [ ] Show completion badge/checkmark
- [ ] Test: Complete quiz → Button shows "Completed ✓"
- [ ] Test: Next day → Button resets to "Start Quiz"

### Phase 4: History (Optional) ✓
- [ ] Create `QuizHistory` model
- [ ] Create `QuizHistoryStore` class
- [ ] Save to history when quiz completes
- [ ] Add history view to see past quizzes
- [ ] Calculate and display streak
- [ ] Test: Complete 3 quizzes → History shows all 3

### Phase 5: Edge Cases ✓
- [ ] Test: Restart quiz → Progress clears
- [ ] Test: Midnight transition → Progress resets for new day
- [ ] Test: Background/foreground → Progress persists
- [ ] Test: Force quit → Progress persists
- [ ] Test: Different day → New quiz, fresh progress

---

## Testing Scenarios

### Test 1: Basic Progress Save/Load
```
1. Open quiz
2. Answer question 1 (correct)
3. Force quit app
4. Reopen app
Expected: Should resume at question 2, score = 1
```

### Test 2: Completion Tracking
```
1. Open quiz
2. Complete all questions
3. See results
4. Close quiz
5. Check TodayView button
Expected: Shows "Quiz Completed ✓" with score
```

### Test 3: Resume from Progress
```
1. Open quiz
2. Answer questions 1-3
3. Close app
4. Reopen app
5. Check TodayView button
Expected: Shows "Continue Quiz (4/5)"
6. Tap button
Expected: Opens at question 4 (not question 1)
```

### Test 4: Retry After Completion
```
1. Complete quiz (score: 3/5)
2. Tap "Retry"
Expected: Clears progress, starts fresh from question 1
```

### Test 5: Next Day Reset
```
1. Complete quiz on Oct 21
2. TodayView shows "Completed ✓"
3. Change device date to Oct 22
4. Check TodayView button
Expected: Shows "Start Quiz" (new quiz available)
```

### Test 6: Midnight Transition
```
1. Start quiz at 11:55 PM
2. Answer 2 questions
3. Wait until 12:01 AM (new day)
4. Check if progress still valid
Expected: Progress cleared OR archived, new quiz available
```

---

## Potential Issues & Solutions

### Issue 1: Date Handling Across Midnight

**Problem**: User starts quiz before midnight, continues after midnight.

**Solution**: Always use date from when quiz was started:
```swift
let progress = QuizProgress(
    date: todayYMD,  // Date when quiz started
    // ...
)

// When loading, check if date matches
if progress.date != todayYMD {
    // Different day, clear progress
    clearProgress()
}
```

### Issue 2: Multiple QuizViewModel Instances

**Problem**: TodayView creates one instance, QuizView creates another.

**Solution**: Pass ViewModel from TodayView to QuizView:
```swift
// In TodayView
@StateObject private var quizVM = QuizViewModel()

// ...

.fullScreenCover(isPresented: $showQuiz) {
    QuizView(vm: quizVM)  // ← Pass existing instance
}

// In QuizView
struct QuizView: View {
    @ObservedObject var vm: QuizViewModel  // ← Use @ObservedObject, not @StateObject
    // ...
}
```

### Issue 3: Large UserDefaults Data

**Problem**: Saving progress + history could grow large.

**Solution**:
- Only keep last 30 days of history
- Use file storage for large datasets
- Periodically clean old data

```swift
func cleanOldHistory() {
    let history = loadAll()
    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    let recent = history.filter { $0.date >= thirtyDaysAgo }

    if let data = try? JSONEncoder().encode(recent) {
        UserDefaults.standard.set(data, forKey: key)
    }
}
```

### Issue 4: Corrupted Progress Data

**Problem**: UserDefaults data could be corrupted.

**Solution**: Add error handling:
```swift
private func loadProgress() {
    let key = progressKey

    guard let data = UserDefaults.standard.data(forKey: key) else {
        currentProgress = nil
        return
    }

    do {
        let progress = try JSONDecoder().decode(QuizProgress.self, from: data)
        // Validate data
        guard progress.date == todayYMD,
              progress.quizTitle == quizOfDay.title,
              progress.currentIndex < totalQuestions else {
            throw NSError(domain: "Invalid progress data", code: 0)
        }
        currentProgress = progress
    } catch {
        print("⚠️ Failed to load progress: \(error)")
        clearProgress() // Clear corrupted data
    }
}
```

---

## Future Enhancements

### 1. Streak System
- Track consecutive days of quiz completion
- Show "🔥 5 day streak!" badge
- Motivate daily engagement
- Reset on missed day (with grace period?)

### 2. Achievements/Badges
- Complete 7 days in a row
- Score 100% on 10 quizzes
- Complete 30 quizzes total
- Perfect week (7/7 days)

### 3. Statistics Dashboard
- Average score over time
- Best/worst topics
- Question accuracy by category
- Time spent on quizzes
- Chart/graph visualizations

### 4. Retry Limits
- Allow 1 retry per day
- Track retry attempts
- Show "1 retry remaining"
- Prevent unlimited retaking

### 5. Quiz History View
- See all past quizzes
- Filter by date range
- Filter by score
- Retake old quizzes (practice mode)

### 6. Leaderboards
- Weekly/monthly rankings
- Compare with friends
- Global leaderboard
- Privacy settings

---

## Summary

### Current State
- ❌ No progress persistence
- ❌ No completion tracking
- ❌ Can retake unlimited times
- ❌ Progress lost on app close

### After Implementation
- ✅ Progress persists across sessions
- ✅ Resume from where you left off
- ✅ Completion tracked per day
- ✅ Smart button shows current state
- ✅ Prevents unlimited retaking
- ✅ Optional history tracking
- ✅ Optional streak system

### Estimated Implementation Time
- **Phase 1 (Basic Persistence)**: 1-2 hours
- **Phase 2 (UI Updates)**: 1-2 hours
- **Phase 3 (Completion Tracking)**: 30 minutes
- **Phase 4 (History - Optional)**: 1-2 hours
- **Total**: 3.5-6.5 hours

---

**End of Quiz Persistence Analysis**
