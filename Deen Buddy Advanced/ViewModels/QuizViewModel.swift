// QuizViewModel.swift
import Foundation
final class QuizViewModel: ObservableObject {
    @Published private(set) var quizzes: [QuizModel]
    @Published private(set) var quizOfDay: QuizModel

    // State
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var selectedIndex: Int? = nil
    @Published private(set) var isLocked: Bool = false
    @Published private(set) var score: Int = 0

    @Published var didFinish: Bool = false   // ⬅️ trigger result screen

    // Quran data for verse fetching
    private let quranSurahs: [Surah]

        var totalQuestions: Int { quizOfDay.questions.count }
        var percent: Double {
            guard totalQuestions > 0 else { return 0 }
            return Double(score) / Double(totalQuestions)
        }

        var gradeText: String {
            switch percent {
            case 0.9...: return AppStrings.quiz.gradeExcellent
            case 0.7..<0.9: return AppStrings.quiz.gradeGreat
            case 0.5..<0.7: return AppStrings.quiz.gradeGood
            default: return AppStrings.quiz.gradeKeepGoing
            }
        }

        var summaryLine: String {
            "\(score)/\(totalQuestions)"
        }
    

    init(quizzes: [QuizModel]? = nil, preselected quiz: QuizModel? = nil) {
        // Load quizzes from JSON file or use provided quizzes
        let resolvedQuizzes = quizzes ?? QuizViewModel.loadQuizzesFromJSON()

        // Load Quran data for verse fetching
        self.quranSurahs = QuranService.shared.loadQuran(language: .english)

        // Pick 5 random questions for today (or use preselected quiz)
        let resolvedQuizOfDay = quiz ?? QuizViewModel.pickDailyRandomQuestions(from: resolvedQuizzes)

        // now assign to self
        self.quizzes = resolvedQuizzes
        self.quizOfDay = resolvedQuizOfDay
    }

    private static func loadQuizzesFromJSON() -> [QuizModel] {
        guard let url = Bundle.main.url(forResource: "quizzes", withExtension: "json") else {
            print("⚠️ quizzes.json not found in bundle, using fallback")
            return fallbackQuizzes()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let quizzes = try decoder.decode([QuizModel].self, from: data)
            print("✅ Loaded \(quizzes.count) quizzes from JSON")
            return quizzes
        } catch {
            print("⚠️ Error loading quizzes.json: \(error), using fallback")
            return fallbackQuizzes()
        }
    }

    private static func fallbackQuizzes() -> [QuizModel] {
        return [
            QuizModel(
                title: "Basics 1",
                questions: [
                    .init(question: "How many Surahs are in the Quran?",
                          answers: ["114", "100", "120", "99"], correctIndex: 0),
                    .init(question: "Which Surah is known as the heart of the Quran?",
                          answers: ["Al-Fatiha", "Yasin", "Al-Baqarah", "Al-Ikhlas"], correctIndex: 1),
                    .init(question: "How many times is Salah obligatory per day?",
                          answers: ["3", "4", "5", "6"], correctIndex: 2),
                ]
            ),
            QuizModel(
                title: "Basics 2",
                questions: [
                    .init(question: "What is the first pillar of Islam?",
                          answers: ["Zakat", "Salah", "Shahada", "Sawm"], correctIndex: 2),
                    .init(question: "Which month is fasting obligatory?",
                          answers: ["Muharram", "Sha'ban", "Ramadan", "Dhul-Hijjah"], correctIndex: 2),
                ]
            ),
            QuizModel(
                title: "Basics 3",
                questions: [
                    .init(question: "What is Zakat?",
                          answers: ["Charity", "Pilgrimage", "Prayer", "Fasting"], correctIndex: 0),
                ]
            )
        ]
    }

    private static func pickDailyRandomQuestions(from quizzes: [QuizModel]) -> QuizModel {
        // Collect all questions from all quizzes
        let allQuestions = quizzes.flatMap { $0.questions }

        guard !allQuestions.isEmpty else {
            return QuizModel(title: "Daily Quiz", questions: [])
        }

        // Use day of year as seed for consistent daily selection
        let cal = Calendar.current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: Date()) ?? 1

        // Create a seeded random number generator for consistent results per day
        var generator = SeededRandomNumberGenerator(seed: UInt64(dayOfYear))

        // Shuffle questions with the seeded generator
        let shuffledQuestions = allQuestions.shuffled(using: &generator)

        // Take up to 5 questions (or all if less than 5 available)
        let dailyQuestions = Array(shuffledQuestions.prefix(5))

        return QuizModel(title: "Daily Quiz", questions: dailyQuestions)
    }

    // Seeded random number generator for consistent daily quiz selection
    private struct SeededRandomNumberGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            self.state = seed
        }

        mutating func next() -> UInt64 {
            // Linear congruential generator
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return state
        }
    }

    var currentQuestion: QuizQuestion { quizOfDay.questions[currentIndex] }
    var isLastQuestion: Bool { currentIndex == max(quizOfDay.questions.count - 1, 0) }

    // Answer correctness state
    var isCorrectAnswer: Bool? {
        guard let selected = selectedIndex else { return nil }
        return selected == currentQuestion.correctIndex
    }

    // Verse reference in "Surah:Verse" format
    var verseReference: String? {
        guard let surah = currentQuestion.surah,
              let verse = currentQuestion.verse else { return nil }
        return "\(surah):\(verse)"
    }

    // Fetch the Quranic verse for the current question
    func fetchVerseForCurrentQuestion() -> Verse? {
        guard let surahName = currentQuestion.surah,
              let verseNumber = currentQuestion.verse else { return nil }

        // Find the surah by transliteration name
        guard let surah = quranSurahs.first(where: { $0.transliteration == surahName }) else {
            print("⚠️ QuizViewModel: Could not find surah '\(surahName)'")
            return nil
        }

        // Find the verse by ID
        guard let verse = surah.verses.first(where: { $0.id == verseNumber }) else {
            print("⚠️ QuizViewModel: Could not find verse \(verseNumber) in \(surahName)")
            return nil
        }

        return verse
    }

    func selectAnswer(_ index: Int) {
        guard !isLocked, quizOfDay.questions.indices.contains(currentIndex) else { return }
        selectedIndex = index
        isLocked = true
        if index == currentQuestion.correctIndex { score += 1 }
    }

    // call when finishing the last question
        func finish() {
            didFinish = true
        }

        // your existing next()
        func next() {
            guard isLocked else { return }
            if isLastQuestion {
                finish()
                return
            }
            currentIndex += 1
            selectedIndex = nil
            isLocked = false
        }

        func restartSameQuiz() {
            currentIndex = 0
            selectedIndex = nil
            isLocked = false
            score = 0
            didFinish = false
        }

    enum AnswerState { case neutral, correctHighlight, wrongHighlight }
    func stateForAnswer(at index: Int) -> AnswerState {
        guard let chosen = selectedIndex else { return .neutral }
        let correct = currentQuestion.correctIndex
        if chosen == correct && index == correct { return .correctHighlight }
        if chosen != correct {
            if index == chosen { return .wrongHighlight }
            if index == correct { return .correctHighlight }
        }
        return .neutral
    }
}
