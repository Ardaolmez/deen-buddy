//
//  WordOfWisdomViewModel.swift
//  Deen Buddy Advanced
//
//  ViewModel for Word of Wisdom feature
//

import Foundation
import Combine

class WordOfWisdomViewModel: ObservableObject {
    @Published var wordOfWisdom: WordOfWisdom?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    private var allWisdoms: [WordOfWisdom] = []

    init() {
        loadWordOfWisdom()
    }

    // Load the daily word of wisdom
    func loadWordOfWisdom() {
        isLoading = true
        errorMessage = nil

        // Load in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Load wisdoms from JSON
            guard let wisdoms = self.loadWisdomsFromJSON() else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Could not load wisdom data"
                }
                return
            }

            self.allWisdoms = wisdoms

            // Get daily wisdom based on date (consistent for the day)
            let dailyWisdom = self.getDailyWisdom(from: wisdoms)

            // Update UI on main thread
            DispatchQueue.main.async {
                self.wordOfWisdom = dailyWisdom
                self.isLoading = false
            }
        }
    }

    // Load wisdoms from JSON file
    private func loadWisdomsFromJSON() -> [WordOfWisdom]? {
        guard let url = Bundle.main.url(forResource: "word_of_wisdom", withExtension: "json") else {
            print("Could not find word_of_wisdom.json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let wisdoms = try JSONDecoder().decode([WordOfWisdom].self, from: data)
            return wisdoms
        } catch {
            print("Error loading word of wisdom: \(error)")
            return nil
        }
    }

    // Get daily wisdom based on current date
    private func getDailyWisdom(from wisdoms: [WordOfWisdom]) -> WordOfWisdom? {
        guard !wisdoms.isEmpty else { return nil }

        // Use current date to generate consistent index for the day
        let calendar = Calendar.current
        let now = Date()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1

        // Get wisdom based on day of year (cycles through all wisdoms)
        let index = dayOfYear % wisdoms.count
        return wisdoms[index]
    }

    // Refresh to get a new wisdom (optional feature)
    func refresh() {
        loadWordOfWisdom()
    }

    // Get truncated quote for card display
    var truncatedQuote: String {
        guard let quote = wordOfWisdom?.quote else { return "" }
        if quote.count > 100 {
            let index = quote.index(quote.startIndex, offsetBy: 100)
            return String(quote[..<index]) + "..."
        }
        return quote
    }
}
