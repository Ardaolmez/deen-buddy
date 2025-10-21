# Daily Reading Goal System - Complete Implementation Plan

## Overviews

Enhance the existing `DailyReadingGoalCard` in the Today tab with a comprehensive goal system supporting two types of reading goals:

1. **Completion Goals**: Finish the entire Quran in a specific timeframe (3 days to 3 months)
2. **Micro-Learning Goals**: Daily 5-minute reading or listening habits

---

## Current State

### Existing Files:
- `/Views/TodayView/DailyReadingGoalCard.swift` - Basic card with hardcoded progress
- `/Utilities/Strings/TodayStrings.swift` - Contains basic strings
- `/Utilities/Colors/AppColors.swift` - Contains color definitions

### Current Card Shows:
- "Daily Reading Goal" header
- Progress bar (40% hardcoded)
- "2 / 5 pages read today" (hardcoded)
- "Continue" button (no action)

---

## Quran Statistics

| Metric | Value |
|--------|-------|
| Total Verses | 6,236 |
| Total Juz | 30 |
| Total Pages | 604 (Madani Mushaf) |

### Goal Calculations:

| Duration | Days | Juz/Day | Verses/Day | Pages/Day | Difficulty |
|----------|------|---------|------------|-----------|------------|
| **3 days** | 3 | 10.00 | 2,079 | 201 | ⚠️ Extreme |
| **1 week** | 7 | 4.29 | 891 | 86 | ⚠️ Very Hard |
| **2 weeks** | 14 | 2.14 | 445 | 43 | 🟡 Moderate |
| **1 month** | 30 | 1.00 | 208 | 20 | ✅ Traditional (Recommended) |
| **3 months** | 90 | 0.33 | 69 | 7 | 🟢 Easy/Gradual |

**Note**: 1 month (1 Juz/day) is the traditional Islamic approach to completing the Quran.

---

## Phase 1: Data Models

### New File: `/Models/ReadingGoalModels.swift`

```swift
//
//  ReadingGoalModels.swift
//  Deen Buddy Advanced
//
//  Data models for daily reading goal system
//

import Foundation

// MARK: - Goal Type

/// Main goal category: Completion or Daily Habit
enum ReadingGoalType: String, Codable {
    case completion      // Finish entire Quran in X days
    case microLearning   // Daily 5-minute habit

    var displayName: String {
        switch self {
        case .completion: return AppStrings.readingGoal.completionGoals
        case .microLearning: return AppStrings.readingGoal.microLearningGoals
        }
    }
}

// MARK: - Completion Goals

/// Duration options for completing the Quran
enum CompletionDuration: String, Codable, CaseIterable {
    case threeDays = "3_days"
    case oneWeek = "1_week"
    case twoWeeks = "2_weeks"
    case oneMonth = "1_month"
    case threeMonths = "3_months"

    var displayName: String {
        switch self {
        case .threeDays: return AppStrings.readingGoal.threeDays
        case .oneWeek: return AppStrings.readingGoal.oneWeek
        case .twoWeeks: return AppStrings.readingGoal.twoWeeks
        case .oneMonth: return AppStrings.readingGoal.oneMonth
        case .threeMonths: return AppStrings.readingGoal.threeMonths
        }
    }

    var days: Int {
        switch self {
        case .threeDays: return 3
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .oneMonth: return 30
        case .threeMonths: return 90
        }
    }

    var totalVerses: Int { 6236 }
    var totalJuz: Int { 30 }
    var totalPages: Int { 604 }

    var versesPerDay: Int {
        totalVerses / days
    }

    var juzPerDay: Double {
        Double(totalJuz) / Double(days)
    }

    var pagesPerDay: Int {
        totalPages / days
    }

    var difficultyLevel: String {
        switch self {
        case .threeDays: return AppStrings.readingGoal.extreme
        case .oneWeek: return AppStrings.readingGoal.veryHard
        case .twoWeeks: return AppStrings.readingGoal.moderate
        case .oneMonth: return AppStrings.readingGoal.traditional
        case .threeMonths: return AppStrings.readingGoal.gradual
        }
    }

    var difficultyColor: String {
        switch self {
        case .threeDays, .oneWeek: return "red"
        case .twoWeeks: return "orange"
        case .oneMonth: return "green"
        case .threeMonths: return "blue"
        }
    }
}

// MARK: - Micro-Learning Goals

/// Type of daily micro-learning activity
enum MicroLearningType: String, Codable, CaseIterable {
    case reading
    case listening

    var displayName: String {
        switch self {
        case .reading: return AppStrings.readingGoal.fiveMinReading
        case .listening: return AppStrings.readingGoal.fiveMinListening
        }
    }

    var description: String {
        switch self {
        case .reading: return AppStrings.readingGoal.readingDescription
        case .listening: return AppStrings.readingGoal.listeningDescription
        }
    }

    var icon: String {
        switch self {
        case .reading: return "book.fill"
        case .listening: return "headphones"
        }
    }

    var targetMinutes: Int { 5 }
    var targetSeconds: Int { 300 }
}

// MARK: - Reading Goal Model

/// Unified model for all reading goals
struct ReadingGoal: Codable, Identifiable {
    let id: UUID
    let type: ReadingGoalType
    let createdDate: Date
    var isActive: Bool

    // MARK: Completion Goal Properties
    var completionDuration: CompletionDuration?
    var completionStartDate: Date?
    var totalVersesRead: Int
    var dailyVerseLog: [String: Int]  // Date string (YYYY-MM-DD) -> verses read

    // MARK: Micro-Learning Goal Properties
    var microType: MicroLearningType?
    var dailyTimeLog: [String: Int]   // Date string (YYYY-MM-DD) -> seconds completed

    // MARK: Initializers

    /// Create a completion goal
    init(completionDuration: CompletionDuration) {
        self.id = UUID()
        self.type = .completion
        self.createdDate = Date()
        self.isActive = true
        self.completionDuration = completionDuration
        self.completionStartDate = Date()
        self.totalVersesRead = 0
        self.dailyVerseLog = [:]
        self.microType = nil
        self.dailyTimeLog = [:]
    }

    /// Create a micro-learning goal
    init(microType: MicroLearningType) {
        self.id = UUID()
        self.type = .microLearning
        self.createdDate = Date()
        self.isActive = true
        self.microType = microType
        self.dailyTimeLog = [:]
        self.completionDuration = nil
        self.completionStartDate = nil
        self.totalVersesRead = 0
        self.dailyVerseLog = [:]
    }

    // MARK: Computed Properties - Common

    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        while true {
            let dateKey = formatter.string(from: checkDate)

            if type == .completion {
                if let verses = dailyVerseLog[dateKey], verses > 0 {
                    streak += 1
                } else {
                    break
                }
            } else {
                if let seconds = dailyTimeLog[dateKey], seconds >= (microType?.targetSeconds ?? 300) {
                    streak += 1
                } else {
                    break
                }
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    // MARK: Computed Properties - Completion Goals

    var daysElapsed: Int? {
        guard type == .completion, let startDate = completionStartDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }

    var daysRemaining: Int? {
        guard type == .completion,
              let duration = completionDuration,
              let elapsed = daysElapsed else { return nil }
        return max(0, duration.days - elapsed)
    }

    var isCompletionGoalFinished: Bool {
        guard type == .completion, let duration = completionDuration else { return false }
        return totalVersesRead >= duration.totalVerses
    }

    var completionPercentage: Double {
        guard type == .completion, let duration = completionDuration else { return 0 }
        return min(1.0, Double(totalVersesRead) / Double(duration.totalVerses))
    }

    var todayVerseTarget: Int? {
        guard type == .completion, let duration = completionDuration else { return nil }
        return duration.versesPerDay
    }

    var todayVersesRead: Int {
        guard type == .completion else { return 0 }
        return dailyVerseLog[todayKey] ?? 0
    }

    var todayCompletionProgress: Double {
        guard let target = todayVerseTarget, target > 0 else { return 0 }
        return min(1.0, Double(todayVersesRead) / Double(target))
    }

    var isOnTrack: Bool {
        guard type == .completion,
              let duration = completionDuration,
              let elapsed = daysElapsed else { return false }

        let expectedVerses = duration.versesPerDay * elapsed
        return totalVersesRead >= expectedVerses
    }

    // MARK: Computed Properties - Micro-Learning Goals

    var todaySecondsCompleted: Int {
        guard type == .microLearning else { return 0 }
        return dailyTimeLog[todayKey] ?? 0
    }

    var todayMicroProgress: Double {
        guard type == .microLearning,
              let target = microType?.targetSeconds,
              target > 0 else { return 0 }
        return min(1.0, Double(todaySecondsCompleted) / Double(target))
    }

    var isTodayMicroCompleted: Bool {
        guard type == .microLearning,
              let target = microType?.targetSeconds else { return false }
        return todaySecondsCompleted >= target
    }

    // MARK: Mutating Functions

    mutating func addVersesRead(_ count: Int, for date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: date)

        dailyVerseLog[dateKey, default: 0] += count
        totalVersesRead += count
    }

    mutating func addTimeCompleted(_ seconds: Int, for date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: date)

        dailyTimeLog[dateKey, default: 0] += seconds
    }

    mutating func deactivate() {
        isActive = false
    }
}
```

---

## Phase 2: ViewModel

### New File: `/ViewModels/ReadingGoalViewModel.swift`

```swift
//
//  ReadingGoalViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for managing reading goals
//

import Foundation
import Combine

class ReadingGoalViewModel: ObservableObject {
    @Published var currentGoal: ReadingGoal?
    @Published var showGoalSelection = false
    @Published var showProgressUpdate = false
    @Published var showTimer = false

    // Timer properties (for micro-learning)
    @Published var timerSeconds: Int = 0
    @Published var isTimerRunning: Bool = false
    private var timer: Timer?

    init() {
        loadGoal()
    }

    // MARK: - Goal Management

    func createCompletionGoal(duration: CompletionDuration) {
        let goal = ReadingGoal(completionDuration: duration)
        currentGoal = goal
        saveGoal()
        showGoalSelection = false
    }

    func createMicroLearningGoal(type: MicroLearningType) {
        let goal = ReadingGoal(microType: type)
        currentGoal = goal
        saveGoal()
        showGoalSelection = false
    }

    func deleteCurrentGoal() {
        currentGoal = nil
        UserDefaults.shared.deleteReadingGoal()
    }

    func isGoalActive() -> Bool {
        return currentGoal?.isActive ?? false
    }

    // MARK: - Completion Goal Actions

    func updateVersesRead(_ count: Int) {
        guard currentGoal?.type == .completion else { return }
        currentGoal?.addVersesRead(count)
        saveGoal()
    }

    func getTodayTarget() -> String {
        guard let goal = currentGoal,
              goal.type == .completion,
              let target = goal.todayVerseTarget else {
            return ""
        }
        return "\(goal.todayVersesRead) / \(target)"
    }

    func getOverallProgress() -> Double {
        return currentGoal?.completionPercentage ?? 0
    }

    func getDaysRemaining() -> Int {
        return currentGoal?.daysRemaining ?? 0
    }

    // MARK: - Micro-Learning Actions

    func startTimer() {
        guard currentGoal?.type == .microLearning else { return }
        isTimerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timerSeconds += 1

            // Auto-complete at target
            if let target = self.currentGoal?.microType?.targetSeconds,
               self.timerSeconds >= target {
                self.completeSession()
            }
        }
    }

    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func completeSession() {
        pauseTimer()
        currentGoal?.addTimeCompleted(timerSeconds)
        saveGoal()
        timerSeconds = 0
        showTimer = false
    }

    func cancelSession() {
        pauseTimer()
        timerSeconds = 0
        showTimer = false
    }

    func getTodayTimeProgress() -> String {
        guard let goal = currentGoal,
              goal.type == .microLearning,
              let target = goal.microType?.targetMinutes else {
            return ""
        }
        let minutes = goal.todaySecondsCompleted / 60
        return "\(minutes) / \(target)"
    }

    // MARK: - Persistence

    private func saveGoal() {
        guard let goal = currentGoal else { return }
        UserDefaults.shared.saveReadingGoal(goal)
    }

    private func loadGoal() {
        currentGoal = UserDefaults.shared.loadReadingGoal()
    }
}
```

---

## Phase 3: Storage

### Update File: `/Utilities/SharedUserDefaults.swift`

Add to existing file:

```swift
extension UserDefaults {
    // Add this key
    private static let readingGoalKey = "currentReadingGoal"

    // MARK: - Reading Goal Data

    func saveReadingGoal(_ goal: ReadingGoal) {
        if let encoded = try? JSONEncoder().encode(goal) {
            set(encoded, forKey: Self.readingGoalKey)
            synchronize()
        }
    }

    func loadReadingGoal() -> ReadingGoal? {
        guard let data = data(forKey: Self.readingGoalKey) else {
            return nil
        }
        return try? JSONDecoder().decode(ReadingGoal.self, from: data)
    }

    func deleteReadingGoal() {
        removeObject(forKey: Self.readingGoalKey)
        synchronize()
    }
}
```

---

## Phase 4: UI Components

### A. Enhanced Daily Reading Goal Card

**Update File**: `/Views/TodayView/DailyReadingGoalCard.swift`

```swift
//
//  DailyReadingGoalCard.swift
//  Deen Buddy Advanced
//
//  Enhanced daily reading goal card with completion and micro-learning goals
//

import SwiftUI

struct DailyReadingGoalCard: View {
    @StateObject private var vm = ReadingGoalViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: vm.currentGoal?.type == .microLearning ?
                      (vm.currentGoal?.microType?.icon ?? "book.fill") : "book.fill")
                    .foregroundColor(AppColors.Today.readingGoalIcon)
                Text(AppStrings.today.dailyReadingGoal)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                // Change goal button (if goal exists)
                if vm.isGoalActive() {
                    Button {
                        vm.showGoalSelection = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }
            }

            // Content based on goal state
            if vm.isGoalActive() {
                if vm.currentGoal?.type == .completion {
                    CompletionGoalContent(vm: vm)
                } else {
                    MicroLearningGoalContent(vm: vm)
                }
            } else {
                NoGoalContent(vm: vm)
            }
        }
        .padding()
        .background(AppColors.Today.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.Today.cardShadow, radius: 8, x: 0, y: 2)
        .sheet(isPresented: $vm.showGoalSelection) {
            ReadingGoalSelectionView(vm: vm)
        }
        .sheet(isPresented: $vm.showProgressUpdate) {
            ProgressUpdateView(vm: vm)
        }
        .fullScreenCover(isPresented: $vm.showTimer) {
            ReadingTimerView(vm: vm)
        }
    }
}

// MARK: - No Goal Content

struct NoGoalContent: View {
    @ObservedObject var vm: ReadingGoalViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text(AppStrings.readingGoal.noGoalMessage)
                .font(.subheadline)
                .foregroundColor(AppColors.Common.secondary)
                .multilineTextAlignment(.center)

            Button {
                vm.showGoalSelection = true
            } label: {
                Text(AppStrings.readingGoal.setGoal)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.Today.readingGoalButton)
                    .foregroundColor(AppColors.Common.white)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Completion Goal Content

struct CompletionGoalContent: View {
    @ObservedObject var vm: ReadingGoalViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Goal name and days remaining
            HStack {
                Text(vm.currentGoal?.completionDuration?.displayName ?? "")
                    .font(.subheadline)
                    .foregroundColor(AppColors.Common.primary)
                Spacer()
                if let days = vm.currentGoal?.daysRemaining {
                    Text(String(format: AppStrings.readingGoal.daysRemaining, days))
                        .font(.caption)
                        .foregroundColor(AppColors.Common.secondary)
                }
            }

            // Overall progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(AppStrings.readingGoal.overallProgress)
                        .font(.caption)
                        .foregroundColor(AppColors.Common.secondary)
                    Spacer()
                    Text("\(Int(vm.getOverallProgress() * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppColors.Today.readingGoalText)
                }

                ProgressView(value: vm.getOverallProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.Today.readingGoalProgress))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }

            // Today's progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.readingGoal.todayTarget)
                        .font(.caption)
                        .foregroundColor(AppColors.Common.secondary)
                    Text(String(format: AppStrings.readingGoal.versesToday,
                                vm.currentGoal?.todayVersesRead ?? 0,
                                vm.currentGoal?.todayVerseTarget ?? 0))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(vm.currentGoal?.isOnTrack ?? false ?
                                       AppColors.ReadingGoal.onTrack :
                                       AppColors.ReadingGoal.behind)
                }

                Spacer()

                Button {
                    vm.showProgressUpdate = true
                } label: {
                    Text(AppStrings.today.continueReading)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.Today.readingGoalButton)
                }
            }

            // Streak indicator
            if let streak = vm.currentGoal?.currentStreak, streak > 0 {
                Text(String(format: AppStrings.readingGoal.currentStreak, streak))
                    .font(.caption)
                    .foregroundColor(AppColors.ReadingGoal.streakColor)
            }
        }
    }
}

// MARK: - Micro-Learning Goal Content

struct MicroLearningGoalContent: View {
    @ObservedObject var vm: ReadingGoalViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Goal type
            Text(vm.currentGoal?.microType?.displayName ?? "")
                .font(.subheadline)
                .foregroundColor(AppColors.Common.primary)

            // Progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.readingGoal.todayProgress)
                        .font(.caption)
                        .foregroundColor(AppColors.Common.secondary)

                    HStack(spacing: 8) {
                        // Circular progress indicator
                        ZStack {
                            Circle()
                                .stroke(AppColors.ReadingGoal.timerBackground, lineWidth: 4)
                                .frame(width: 40, height: 40)

                            Circle()
                                .trim(from: 0, to: vm.currentGoal?.todayMicroProgress ?? 0)
                                .stroke(AppColors.ReadingGoal.timerProgress, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))

                            Text("\(vm.currentGoal?.todaySecondsCompleted ?? 0 / 60)")
                                .font(.caption2.weight(.bold))
                        }

                        Text(String(format: AppStrings.readingGoal.minutesToday,
                                    (vm.currentGoal?.todaySecondsCompleted ?? 0) / 60,
                                    vm.currentGoal?.microType?.targetMinutes ?? 5))
                            .font(.subheadline.weight(.semibold))
                    }
                }

                Spacer()

                // Start/Continue button
                Button {
                    vm.showTimer = true
                } label: {
                    HStack {
                        Image(systemName: vm.currentGoal?.isTodayMicroCompleted ?? false ?
                              "checkmark.circle.fill" : "play.circle.fill")
                        Text(vm.currentGoal?.isTodayMicroCompleted ?? false ?
                             AppStrings.readingGoal.completed :
                             AppStrings.readingGoal.startSession)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.Today.readingGoalButton)
                }
                .disabled(vm.currentGoal?.isTodayMicroCompleted ?? false)
            }

            // Streak indicator
            if let streak = vm.currentGoal?.currentStreak, streak > 0 {
                Text(String(format: AppStrings.readingGoal.currentStreak, streak))
                    .font(.caption)
                    .foregroundColor(AppColors.ReadingGoal.streakColor)
            }
        }
    }
}

#Preview {
    DailyReadingGoalCard()
        .padding()
}
```

---

### B. Goal Selection View

**New File**: `/Views/TodayView/ReadingGoalSelectionView.swift`

```swift
//
//  ReadingGoalSelectionView.swift
//  Deen Buddy Advanced
//
//  Sheet for selecting reading goal type and duration
//

import SwiftUI

struct ReadingGoalSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ReadingGoalViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Completion Goals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppStrings.readingGoal.completionGoals)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(AppColors.Common.primary)

                        Text(AppStrings.readingGoal.completionDescription)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Common.secondary)

                        ForEach(CompletionDuration.allCases, id: \.self) { duration in
                            CompletionGoalCard(duration: duration) {
                                vm.createCompletionGoal(duration: duration)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // Micro-Learning Goals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppStrings.readingGoal.microLearningGoals)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(AppColors.Common.primary)

                        Text(AppStrings.readingGoal.microDescription)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Common.secondary)

                        ForEach(MicroLearningType.allCases, id: \.self) { type in
                            MicroLearningGoalCard(type: type) {
                                vm.createMicroLearningGoal(type: type)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(AppStrings.readingGoal.chooseGoal)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Completion Goal Card

struct CompletionGoalCard: View {
    let duration: CompletionDuration
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(duration.displayName)
                        .font(.headline)
                        .foregroundColor(AppColors.Common.primary)
                    Spacer()
                    Text(duration.difficultyLevel)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(duration.difficultyColor).opacity(0.2))
                        .foregroundColor(Color(duration.difficultyColor))
                        .cornerRadius(8)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.2f", duration.juzPerDay))
                            .font(.title3.weight(.bold))
                            .foregroundColor(AppColors.Common.primary)
                        Text(AppStrings.readingGoal.juzPerDay)
                            .font(.caption2)
                            .foregroundColor(AppColors.Common.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(duration.versesPerDay)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(AppColors.Common.primary)
                        Text(AppStrings.readingGoal.versesPerDay)
                            .font(.caption2)
                            .foregroundColor(AppColors.Common.secondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(duration.pagesPerDay)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(AppColors.Common.primary)
                        Text(AppStrings.readingGoal.pagesPerDay)
                            .font(.caption2)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.ReadingGoal.completionCardBg)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Micro-Learning Goal Card

struct MicroLearningGoalCard: View {
    let type: MicroLearningType
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.ReadingGoal.microIconColor)
                    .frame(width: 60, height: 60)
                    .background(AppColors.ReadingGoal.microIconBg)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(AppColors.Common.primary)
                    Text(type.description)
                        .font(.subheadline)
                        .foregroundColor(AppColors.Common.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.ReadingGoal.microLearningCardBg)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReadingGoalSelectionView(vm: ReadingGoalViewModel())
}
```

---

### C. Progress Update View

**New File**: `/Views/TodayView/ProgressUpdateView.swift`

```swift
//
//  ProgressUpdateView.swift
//  Deen Buddy Advanced
//
//  Quick update sheet for completion goal progress
//

import SwiftUI

struct ProgressUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ReadingGoalViewModel
    @State private var customVerses: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Today's progress summary
                VStack(spacing: 12) {
                    Text(AppStrings.readingGoal.todayProgress)
                        .font(.headline)

                    HStack {
                        Text("\(vm.currentGoal?.todayVersesRead ?? 0)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AppColors.Today.readingGoalText)
                        Text("/ \(vm.currentGoal?.todayVerseTarget ?? 0)")
                            .font(.title2)
                            .foregroundColor(AppColors.Common.secondary)
                    }

                    Text(AppStrings.readingGoal.versesRead)
                        .font(.subheadline)
                        .foregroundColor(AppColors.Common.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.Common.systemGray6)
                .cornerRadius(16)

                // Quick add buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text(AppStrings.readingGoal.quickAdd)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.Common.secondary)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickAddButton(label: "+1 Page", verses: 15) {
                            vm.updateVersesRead(15)
                        }
                        QuickAddButton(label: "+5 Pages", verses: 75) {
                            vm.updateVersesRead(75)
                        }
                        QuickAddButton(label: "+10 Pages", verses: 150) {
                            vm.updateVersesRead(150)
                        }
                        QuickAddButton(label: "+1 Juz", verses: 208) {
                            vm.updateVersesRead(208)
                        }
                        QuickAddButton(label: "+2 Juz", verses: 416) {
                            vm.updateVersesRead(416)
                        }
                        QuickAddButton(label: "+3 Juz", verses: 624) {
                            vm.updateVersesRead(624)
                        }
                    }
                }

                // Custom verse input
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.readingGoal.customAmount)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.Common.secondary)

                    HStack {
                        TextField(AppStrings.readingGoal.enterVerses, text: $customVerses)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            if let verses = Int(customVerses), verses > 0 {
                                vm.updateVersesRead(verses)
                                customVerses = ""
                            }
                        } label: {
                            Text(AppStrings.readingGoal.add)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.Today.readingGoalButton)
                                .foregroundColor(AppColors.Common.white)
                                .cornerRadius(8)
                        }
                        .disabled(customVerses.isEmpty)
                    }
                }

                Spacer()

                // Done button
                Button {
                    dismiss()
                } label: {
                    Text(AppStrings.readingGoal.done)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.Common.blue)
                        .foregroundColor(AppColors.Common.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle(AppStrings.readingGoal.updateProgress)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Quick Add Button

struct QuickAddButton: View {
    let label: String
    let verses: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppColors.Common.primary)
                Text("\(verses) verses")
                    .font(.caption2)
                    .foregroundColor(AppColors.Common.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppColors.ReadingGoal.quickAddBg)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProgressUpdateView(vm: ReadingGoalViewModel())
}
```

---

### D. Reading Timer View

**New File**: `/Views/TodayView/ReadingTimerView.swift`

```swift
//
//  ReadingTimerView.swift
//  Deen Buddy Advanced
//
//  Full-screen timer for micro-learning sessions
//

import SwiftUI

struct ReadingTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ReadingGoalViewModel

    var progress: Double {
        guard let target = vm.currentGoal?.microType?.targetSeconds,
              target > 0 else { return 0 }
        return min(1.0, Double(vm.timerSeconds) / Double(target))
    }

    var remainingSeconds: Int {
        let target = vm.currentGoal?.microType?.targetSeconds ?? 300
        return max(0, target - vm.timerSeconds)
    }

    var body: some View {
        ZStack {
            // Background
            AppColors.Common.systemBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        vm.cancelSession()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }
                .padding()

                Spacer()

                // Goal type
                VStack(spacing: 8) {
                    Image(systemName: vm.currentGoal?.microType?.icon ?? "book.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.ReadingGoal.timerProgress)

                    Text(vm.currentGoal?.microType?.displayName ?? "")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(AppColors.Common.primary)
                }

                // Circular timer
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(AppColors.ReadingGoal.timerBackground, lineWidth: 20)
                        .frame(width: 280, height: 280)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppColors.ReadingGoal.timerProgress, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)

                    // Time display
                    VStack(spacing: 8) {
                        Text(formatTime(remainingSeconds))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.ReadingGoal.timerText)

                        Text(AppStrings.readingGoal.remaining)
                            .font(.subheadline)
                            .foregroundColor(AppColors.Common.secondary)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: 24) {
                    // Pause/Resume button
                    Button {
                        if vm.isTimerRunning {
                            vm.pauseTimer()
                        } else {
                            vm.startTimer()
                        }
                    } label: {
                        HStack {
                            Image(systemName: vm.isTimerRunning ? "pause.fill" : "play.fill")
                            Text(vm.isTimerRunning ?
                                 AppStrings.readingGoal.pause :
                                 AppStrings.readingGoal.resume)
                        }
                        .font(.headline)
                        .foregroundColor(AppColors.Common.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.ReadingGoal.timerProgress)
                        .cornerRadius(16)
                    }

                    // Complete button (if target reached)
                    if remainingSeconds == 0 {
                        Button {
                            vm.completeSession()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(AppStrings.readingGoal.complete)
                            }
                            .font(.headline)
                            .foregroundColor(AppColors.Common.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.Common.green)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            vm.startTimer()
        }
        .onDisappear {
            vm.pauseTimer()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    ReadingTimerView(vm: ReadingGoalViewModel())
}
```

---

## Phase 5: Strings

### Update File: `/Utilities/Strings/TodayStrings.swift`

Add new struct for reading goal strings:

```swift
// Add to TodayStrings.swift or create new ReadingGoalStrings.swift

struct ReadingGoalStrings {
    // Goal Types
    static let completionGoals = "Completion Goals"
    static let microLearningGoals = "Daily Micro-Learning"
    static let chooseGoal = "Choose Your Reading Goal"
    static let setGoal = "Set Reading Goal"
    static let noGoalMessage = "Set a daily reading goal to track your Quran progress"

    // Completion Durations
    static let threeDays = "3 Days"
    static let oneWeek = "1 Week"
    static let twoWeeks = "2 Weeks"
    static let oneMonth = "1 Month"
    static let threeMonths = "3 Months"

    // Difficulty Levels
    static let extreme = "Extreme"
    static let veryHard = "Very Hard"
    static let moderate = "Moderate"
    static let traditional = "Traditional"
    static let gradual = "Gradual"

    // Micro-Learning Types
    static let fiveMinReading = "5 Min Reading Daily"
    static let fiveMinListening = "5 Min Listening Daily"
    static let readingDescription = "Build a consistent reading habit"
    static let listeningDescription = "Learn through audio recitation"

    // Descriptions
    static let completionDescription = "Choose how fast you want to complete the Quran"
    static let microDescription = "Start with small daily habits"

    // Progress
    static let overallProgress = "Overall Progress"
    static let todayProgress = "Today's Progress"
    static let todayTarget = "Today's Target"
    static let versesToday = "%d / %d verses"
    static let minutesToday = "%d / %d minutes"
    static let versesRead = "verses read"
    static let daysRemaining = "%d days remaining"
    static let currentStreak = "%d day streak 🔥"

    // Metrics
    static let juzPerDay = "Juz/day"
    static let versesPerDay = "verses/day"
    static let pagesPerDay = "pages/day"

    // Actions
    static let startSession = "Start"
    static let pauseSession = "Pause"
    static let resume = "Resume"
    static let completeSession = "Complete"
    static let completed = "Completed ✓"
    static let changeGoal = "Change Goal"
    static let updateProgress = "Update Progress"
    static let done = "Done"

    // Timer
    static let remaining = "remaining"

    // Progress Update
    static let quickAdd = "Quick Add"
    static let customAmount = "Custom Amount"
    static let enterVerses = "Enter verses"
    static let add = "Add"
}

// Update AppStrings to include reading goal strings
extension AppStrings {
    static let readingGoal = ReadingGoalStrings.self
}
```

---

## Phase 6: Colors

### Update File: `/Utilities/Colors/AppColors.swift`

Add new color struct:

```swift
// Add to AppColors.swift

struct ReadingGoal {
    // Goal selection cards
    static let completionCardBg = Color.blue.opacity(0.08)
    static let microLearningCardBg = Color.green.opacity(0.08)
    static let microIconBg = Color.green.opacity(0.15)
    static let microIconColor = Color.green

    // Progress states
    static let onTrack = Color.green
    static let behind = Color.orange
    static let ahead = Color.blue

    // Timer
    static let timerProgress = Color.green
    static let timerBackground = Color(.systemGray5)
    static let timerText = Color.primary

    // Streak
    static let streakColor = Color.orange

    // Quick add buttons
    static let quickAddBg = Color(.systemGray6)
}

// Update AppColors struct
struct AppColors {
    // ... existing color structs ...

    // MARK: - Reading Goal Colors
    static let ReadingGoal = ReadingGoalColors.self // or just use ReadingGoal directly
}
```

---

## Implementation Checklist

### Phase 1: Data & Logic
- [ ] Create `ReadingGoalModels.swift` with all enums and struct
- [ ] Create `ReadingGoalViewModel.swift` with goal management logic
- [ ] Update `SharedUserDefaults.swift` with save/load/delete methods
- [ ] Test data persistence

### Phase 2: UI - Core
- [ ] Update `DailyReadingGoalCard.swift` with three states
- [ ] Create `ReadingGoalSelectionView.swift` with goal options
- [ ] Test goal selection and card updates

### Phase 3: UI - Completion Goals
- [ ] Create `CompletionGoalContent` component
- [ ] Create `ProgressUpdateView.swift` for verse tracking
- [ ] Test completion goal flow

### Phase 4: UI - Micro-Learning
- [ ] Create `MicroLearningGoalContent` component
- [ ] Create `ReadingTimerView.swift` with timer logic
- [ ] Test micro-learning goal flow

### Phase 5: Strings & Colors
- [ ] Add all strings to `TodayStrings.swift` or new file
- [ ] Add all colors to `AppColors.swift`
- [ ] Replace all hardcoded text and colors

### Phase 6: Integration
- [ ] Test switching between goal types
- [ ] Test streak calculation
- [ ] Test progress persistence
- [ ] Handle edge cases (goal completion, reset, etc.)

### Phase 7: Polish
- [ ] Add animations
- [ ] Add haptic feedback
- [ ] Add completion celebrations
- [ ] Test dark mode
- [ ] Test on different screen sizes

---

## User Flow Diagrams

### Flow 1: First Time User
```
Today Tab
  └─> DailyReadingGoalCard (No Goal)
      └─> Tap "Set Reading Goal"
          └─> ReadingGoalSelectionView
              ├─> Select Completion Goal (e.g., "1 Month")
              │   └─> Card updates to show completion progress
              └─> OR Select Micro-Learning (e.g., "5 Min Reading")
                  └─> Card updates to show timer
```

### Flow 2: Completion Goal User
```
Today Tab
  └─> DailyReadingGoalCard (Completion Goal Active)
      ├─> Shows: "Finish in 1 Month - 25 days remaining"
      ├─> Overall progress: 15% bar
      ├─> Today's progress: "50 / 208 verses"
      └─> Tap "Continue Reading"
          └─> ProgressUpdateView
              ├─> Quick add: +1 Page, +5 Pages, +1 Juz
              ├─> Custom input: Enter verses manually
              └─> Tap "Done" → Updates goal
```

### Flow 3: Micro-Learning User
```
Today Tab
  └─> DailyReadingGoalCard (Micro-Learning Active)
      ├─> Shows: "5 Min Reading Daily"
      ├─> Circular progress: "2:30 / 5:00"
      ├─> Streak: "🔥 7 day streak"
      └─> Tap "Start"
          └─> ReadingTimerView (Full Screen)
              ├─> Large circular timer
              ├─> Pause/Resume button
              ├─> Auto-completes at 5:00
              └─> Tap "Complete" → Updates goal
```

### Flow 4: Changing Goals
```
DailyReadingGoalCard (Any Goal Active)
  └─> Tap ellipsis icon (•••)
      └─> ReadingGoalSelectionView
          ├─> Select new goal
          └─> Old goal is replaced
```

---

## Edge Cases to Handle

1. **Goal Completion**: Show celebration, offer to set new goal
2. **Missed Days**: Don't break streak on first miss, show encouragement
3. **Over-Achievement**: Celebrate when user exceeds daily target
4. **Timer Interruptions**: Save partial progress if app backgrounded
5. **Goal Switching**: Confirm before replacing active goal
6. **Data Migration**: Handle app updates gracefully
7. **Offline Mode**: All functionality works without internet

---

## Future Enhancements (Optional)

1. **Notifications**: Remind users of daily goal
2. **Achievements**: Badges for milestones (7-day streak, first Juz, etc.)
3. **History**: View past goals and completion rates
4. **Analytics**: Charts showing progress over time
5. **Social**: Share achievements with friends
6. **Audio Integration**: Built-in Quran audio player for listening goal
7. **Reading Position**: Auto-bookmark and resume from last position
8. **Multiple Goals**: Allow both completion + micro-learning simultaneously
9. **Custom Durations**: Let users set custom timeframes
10. **Widgets**: Show progress on home screen widget

---

## Testing Strategy

### Unit Tests
- [ ] Test `ReadingGoal` computed properties
- [ ] Test streak calculation logic
- [ ] Test progress percentage calculations
- [ ] Test date formatting

### UI Tests
- [ ] Test goal selection flow
- [ ] Test progress updates
- [ ] Test timer functionality
- [ ] Test goal switching

### Integration Tests
- [ ] Test UserDefaults persistence
- [ ] Test app restart with active goal
- [ ] Test date changes (midnight reset)

---

## Estimated Implementation Time

| Phase | Estimated Time |
|-------|---------------|
| Phase 1: Data Models | 1-2 hours |
| Phase 2: ViewModel | 1-2 hours |
| Phase 3: Storage | 30 minutes |
| Phase 4A: Enhanced Card | 1 hour |
| Phase 4B: Goal Selection | 1-2 hours |
| Phase 4C: Progress Update | 1 hour |
| Phase 4D: Timer View | 1-2 hours |
| Phase 5: Strings & Colors | 30 minutes |
| Phase 6: Testing & Polish | 2-3 hours |
| **Total** | **9-14 hours** |

---

## Notes

- All strings must use centralized `AppStrings.readingGoal.*`
- All colors must use centralized `AppColors.ReadingGoal.*`
- Maintain existing app folder structure
- Follow SwiftUI best practices
- Ensure dark mode compatibility
- Test on iPhone and iPad
- Keep performance optimal (avoid heavy computations)

---

**End of Implementation Plan**

Ready to implement when you are! 🚀
