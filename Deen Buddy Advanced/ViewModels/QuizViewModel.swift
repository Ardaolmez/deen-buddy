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
        let resolvedQuizOfDay = quiz ?? QuizViewModel.pickQuizOfDay(from: resolvedQuizzes)

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

    private static func pickQuizOfDay(from quizzes: [QuizModel]) -> QuizModel {
        guard !quizzes.isEmpty else { return QuizModel(title: "Empty", questions: []) }
        let cal = Calendar.current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quizzes[(dayOfYear - 1) % quizzes.count]
    }

    var currentQuestion: QuizQuestion { quizOfDay.questions[currentIndex] }
    var isLastQuestion: Bool { currentIndex == max(quizOfDay.questions.count - 1, 0) }
    var progressText: String { String(format: AppStrings.quiz.progressText, currentIndex + 1, quizOfDay.questions.count) }

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
