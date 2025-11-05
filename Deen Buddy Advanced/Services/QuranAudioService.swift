//
//  QuranAudioService.swift
//  Deen Buddy Advanced
//
//  Service for fetching Quran audio from Quran.com API
//

import Foundation

class QuranAudioService {
    static let shared = QuranAudioService()

    private let baseURL = "https://api.quran.com/api/v4"
    private let session: URLSession

    // Cache
    private var cachedReciters: [Reciter]?
    private var cachedVerses: [Int: [AudioVerse]] = [:] // [surahID: verses]

    // User preferences
    private let selectedReciterKey = "selectedReciterID"

    var selectedReciterID: Int {
        get {
            let stored = UserDefaults.standard.integer(forKey: selectedReciterKey)
            return stored > 0 ? stored : 7 // Default to Mishari al-Afasy
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedReciterKey)
            // Clear cached verses when reciter changes
            cachedVerses.removeAll()
        }
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - API Methods

    /// Fetch available reciters
    func fetchReciters() async throws -> [Reciter] {
        // Return cached reciters if available (for fast loading)
        if let cached = cachedReciters, !cached.isEmpty {
            return cached
        }

        let endpoint = "\(baseURL)/resources/recitations"
        guard let url = URL(string: endpoint) else {
            throw QuranAudioError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuranAudioError.networkError
            }

            guard httpResponse.statusCode == 200 else {
                throw QuranAudioError.serverError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            do {
                let recitersResponse = try decoder.decode(RecitersResponse.self, from: data)

                // Cache the results
                cachedReciters = recitersResponse.recitations
                return recitersResponse.recitations
            } catch {
                throw QuranAudioError.decodingError
            }
        } catch let error as QuranAudioError {
            throw error
        } catch {
            throw QuranAudioError.networkError
        }
    }

    /// Fetch verses with audio for a surah
    func fetchVersesAudio(surahID: Int, reciterID: Int? = nil) async throws -> [AudioVerse] {
        let reciter = reciterID ?? selectedReciterID

        // Check cache
        if let cached = cachedVerses[surahID] {
            return cached
        }

        let endpoint = "\(baseURL)/verses/by_chapter/\(surahID)?audio=\(reciter)&words=true&per_page=300"
        guard let url = URL(string: endpoint) else {
            throw QuranAudioError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw QuranAudioError.networkError
        }

        let decoder = JSONDecoder()
        let versesResponse = try decoder.decode(VersesAudioResponse.self, from: data)

        // Cache the result (sorted by verse number to ensure sequential playback)
        let sortedVerses = versesResponse.verses.sorted { $0.verseNumber < $1.verseNumber }
        cachedVerses[surahID] = sortedVerses

        return sortedVerses
    }

    /// Get selected reciter info
    func getSelectedReciter() async throws -> Reciter? {
        let reciters = try await fetchReciters()
        return reciters.first { $0.id == selectedReciterID }
    }

    // MARK: - Cache Management

    func clearCache() {
        cachedReciters = nil
        cachedVerses.removeAll()
    }
}

// MARK: - Error Types

enum QuranAudioError: LocalizedError {
    case invalidURL
    case networkError
    case serverError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError:
            return "Network connection failed. Please check your internet connection."
        case .serverError(let statusCode):
            return "Server error (code \(statusCode)). Please try again later."
        case .decodingError:
            return "Failed to process server response"
        }
    }
}

// MARK: - Popular Reciters

extension QuranAudioService {
    static var popularReciters: [(id: Int, name: String)] {
        return [
            (7, "Mishari Rashid al-Afasy"),
            (3, "Abdur-Rahman as-Sudais"),
            (4, "Abu Bakr al-Shatri"),
            (6, "Mahmoud Khalil Al-Husary"),
            (2, "AbdulBaset AbdulSamad (Murattal)"),
            (10, "Sa'ud ash-Shuraym")
        ]
    }
}
