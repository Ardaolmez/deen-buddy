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

    /// Send a message and get a reply from the backend
    func reply(to userText: String) -> AnyPublisher<ChatServiceResponse, Never> {
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

        // Request body
        let body: [String: Any] = ["question": userText]
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
                    citations = citationsArray.compactMap { citationDict in
                        guard let ref = citationDict["ref"] as? String,
                              let surah = citationDict["surah"] as? String,
                              let ayah = citationDict["ayah"] as? Int,
                              let text = citationDict["text"] as? String else {
                            return nil
                        }
                        return Citation(ref: ref, surah: surah, ayah: ayah, text: text)
                    }
                }

                return ChatServiceResponse(answer: answer, citations: citations)
            }
            .catch { error -> Just<ChatServiceResponse> in
                // Handle all errors gracefully
                print("CloudflareChatService error: \(error)")
                return Just(ChatServiceResponse(
                    answer: "Sorry, I couldn't reach myDeen right now. Please try again.",
                    citations: []
                ))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
