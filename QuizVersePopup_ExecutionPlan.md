# Execution Plan: Clickable Quran Verse Reference Pop-up

## Goal
Make the reference text (e.g., "Al-Fatiha:1") in the quiz explanation clickable. When clicked, open a pop-up sheet (not full page) showing the Quran scrolled to that exact verse.

---

## Phase 1: Make Reference Text Clickable in QuestionCard

**File:** `/Views/QuizView/QuestionCard.swift`

**Changes:**
1. Add a callback parameter to handle reference click:
   ```swift
   let onReferenceClick: (() -> Void)?
   ```

2. Convert the reference Text to a Button:
   ```swift
   if let ref = reference {
       HStack(spacing: 4) {
           Text(AppStrings.quiz.reference)
               .foregroundColor(AppColors.Quiz.explanationReference)

           Button {
               onReferenceClick?()
           } label: {
               Text(ref)
                   .foregroundColor(.blue)
                   .underline()
           }
           .buttonStyle(.plain)
       }
   }
   ```

---

## Phase 2: Add State Management in QuizView

**File:** `/Views/QuizView/QuizView.swift`

**Changes:**
1. Add state for pop-up:
   ```swift
   @State private var showVersePopup: Bool = false
   ```

2. Update QuestionCard call to include callback:
   ```swift
   QuestionCard(
       question: vm.currentQuestion.question,
       showExplanation: showExplanation,
       isCorrect: vm.isCorrectAnswer,
       correctAnswer: vm.isCorrectAnswer == false ? vm.currentQuestion.answers[vm.currentQuestion.correctIndex] : nil,
       explanation: vm.currentQuestion.explanation,
       reference: vm.verseReference,
       onReferenceClick: {
           showVersePopup = true
       }
   )
   ```

---

## Phase 3: Create VersePopupView Component

**New File:** `/Views/QuizView/VersePopupView.swift`

**Purpose:** Display a scrollable Quran view focused on a specific verse

**Implementation:**
```swift
import SwiftUI

struct VersePopupView: View {
    @Environment(\.dismiss) private var dismiss
    let surahName: String
    let verseNumber: Int

    @State private var surah: Surah?

    var body: some View {
        NavigationStack {
            Group {
                if let surah = surah {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Surah Header
                                VStack(spacing: 8) {
                                    Text(surah.name)
                                        .font(.system(.title, design: .serif).weight(.bold))
                                    Text(surah.transliteration)
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                    Text(surah.translation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()

                                // Verses
                                ForEach(surah.verses) { verse in
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Verse number
                                        Text("Verse \(verse.id)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        // Arabic text
                                        Text(verse.text)
                                            .font(.system(.title3, design: .serif))
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .fixedSize(horizontal: false, vertical: true)

                                        // Translation
                                        if let translation = verse.translation {
                                            Text(translation)
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(verse.id == verseNumber ? Color.yellow.opacity(0.2) : Color(.systemGray6))
                                    )
                                    .id(verse.id) // Important for scrolling
                                }
                                .padding(.horizontal)
                            }
                        }
                        .onAppear {
                            // Scroll to target verse with animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(verseNumber, anchor: .top)
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle(surahName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadSurah()
        }
    }

    private func loadSurah() {
        let surahs = QuranService.shared.loadQuran(language: .english)
        surah = surahs.first { $0.transliteration == surahName }
    }
}
```

**Key Technical Details:**
- Uses `ScrollViewReader` to programmatically scroll to specific verse
- Uses `.id(verse.id)` to tag each verse for scrolling
- Highlights target verse with yellow background
- Loads only the relevant Surah using QuranService
- Minimal UI focused on verse context

---

## Phase 4: Display Pop-up from QuizView

**File:** `/Views/QuizView/QuizView.swift`

**Changes:**
Add sheet modifier after the fullScreenCover:
```swift
.sheet(isPresented: $showVersePopup) {
    if let surahName = vm.currentQuestion.surah,
       let verseNum = vm.currentQuestion.verse {
        VersePopupView(surahName: surahName, verseNumber: verseNum)
    }
}
```

---

## Phase 5: Update QuestionCard Preview (Optional)

**File:** `/Views/QuizView/QuestionCard.swift`

Update the preview to include the callback:
```swift
#Preview {
    QuestionCard(
        question: "Sample question?",
        showExplanation: true,
        isCorrect: true,
        correctAnswer: nil,
        explanation: "This is an explanation.",
        reference: "Al-Fatiha:1",
        onReferenceClick: {
            print("Reference clicked")
        }
    )
}
```

---

## Edge Cases to Handle

1. **Missing Surah Data:** If surah name doesn't match, show error message
2. **Invalid Verse Number:** If verse doesn't exist in surah, scroll to beginning
3. **Loading State:** Show ProgressView while loading Quran data
4. **Dismiss Behavior:** Allow user to swipe down or tap "Done" to close

---

## Testing Checklist

- [ ] Reference text appears as blue, underlined, and clickable
- [ ] Tapping reference opens pop-up (not full screen)
- [ ] Pop-up shows correct Surah
- [ ] Pop-up auto-scrolls to correct verse
- [ ] Target verse is highlighted
- [ ] User can read verses above and below for context
- [ ] "Done" button dismisses pop-up
- [ ] Works in both light and dark mode
- [ ] Works for all quiz questions with verse references

---

## Estimated Complexity

**Time:** 30-45 minutes
**Difficulty:** Medium
**Files to Modify:** 2 (QuestionCard.swift, QuizView.swift)
**Files to Create:** 1 (VersePopupView.swift)

---

## Optional Enhancements (Future)

1. Add ability to bookmark/save verses from pop-up
2. Add translation language toggle in pop-up
3. Add share button to share specific verse
4. Add audio playback for verse recitation
5. Remember last scroll position for better UX

---

## Notes

- This implementation follows the existing app architecture
- Uses QuranService for data consistency
- Maintains separation of concerns (View/ViewModel)
- Pop-up is lightweight and focused on single purpose
- Easy to test and maintain
