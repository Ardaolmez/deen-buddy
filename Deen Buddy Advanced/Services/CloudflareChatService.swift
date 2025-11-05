//
//  CloudflareChatService.swift
//  Deen Buddy Advanced
//
//  Created by Claude on 10/24/25.
//

import Foundation
import Combine

/// Chat service that connects to Cloudflare Workers backend
final class CloudflareChatService: ChatService {
    private let baseURL: String
    private let session: URLSession

    /// Initialize with your Cloudflare Workers endpoint
    /// - Parameter baseURL: Your Workers URL (default: deen-buddy-backend.vibalyze.workers.dev)
    init(baseURL: String = "https://deen-buddy-backend.vibalyze.workers.dev") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }

    /// Send a message and get a reply from the backend with conversation history
    func reply(to userText: String, history: [ChatMessage]) -> AnyPublisher<ChatServiceResponse, Never> {
        // Build request
        guard let url = URL(string: "\(baseURL)/api/ask") else {
            return Just(ChatServiceResponse(
                answer: "Error: Invalid backend URL",
                citations: []
            )).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build messages array in OpenAI format
        var messages: [[String: String]] = []

        // Add conversation history (user and bot messages)
        for msg in history {
            let role = msg.role == .user ? "user" : "assistant"
            messages.append(["role": role, "content": msg.text])
        }

        // Add current user message
        messages.append(["role": "user", "content": userText])

        // Request body
        let body: [String: Any] = ["messages": messages]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Just(ChatServiceResponse(
                answer: "Error: Could not encode request",
                citations: []
            )).eraseToAnyPublisher()
        }
        request.httpBody = jsonData

        // Make API call
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> ChatServiceResponse in
                // Check HTTP status
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                // Parse JSON response
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = json["success"] as? Bool,
                      success,
                      let responseData = json["data"] as? [String: Any],
                      let answer = responseData["answer"] as? String else {
                    throw URLError(.cannotParseResponse)
                }


                // Parse citations array
                var citations: [Citation] = []
                if let citationsArray = responseData["citations"] as? [[String: Any]] {
                    citations = citationsArray.compactMap { citationDict -> Citation? in
                        guard let ref = citationDict["ref"] as? String,
                              let surahNumber = citationDict["surah"] as? Int,
                              let verseNumber = citationDict["ayah"] as? Int else {
                            print("🌐 [API] Failed to parse citation: \(citationDict)")
                            return nil
                        }

                        // Fetch surah name and verse text from QuranService
                        let quranService = QuranService.shared
                        let surahs = quranService.loadQuran()

                        guard let surah = quranService.getSurah(id: surahNumber, from: surahs),
                              let verse = surah.verses.first(where: { $0.id == verseNumber }),
                              let verseText = verse.translation else {
                            print("🌐 [API] Could not find Surah \(surahNumber) Verse \(verseNumber)")
                            return nil
                        }

                        return Citation(
                            ref: ref,
                            surah: surah.transliteration,
                            ayah: verseNumber,
                            text: verseText
                        )
                    }
                }

                return ChatServiceResponse(answer: answer, citations: citations)
            }
            .catch { error -> Just<ChatServiceResponse> in
                // Handle all errors gracefully
                print("CloudflareChatService error: \(error)")
                return Just(ChatServiceResponse(
                    answer: "Sorry, I couldn't reach Imam Buddy right now. Please try again.",
                    citations: []
                ))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
