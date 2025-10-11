//
//  GeminiChatService.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/7/25.
//

// Services/GeminiChatService.swift
import Foundation
import Combine
import GoogleGenerativeAI

final class GeminiChatService: ChatService {
    private let model: GenerativeModel

    /// - Parameters:
    ///   - apiKey: Your Google AI Studio API key
    ///   - modelName: e.g. "gemini-1.5-flash" (fast) or "gemini-1.5-pro" (stronger)
    ///   - systemInstruction: Optional system prompt to set persona/tone
    init(
        apiKey: String,
        modelName: String = "gemini-1.5-flash",
        systemInstruction: String? = nil,
        temperature: Float = 0.7,
        maxOutputTokens: Int = 512
    ) {
        let config = GenerationConfig(
            temperature: temperature,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: maxOutputTokens
        )

        // Adjust safety to your needs; here we allow everything (you can tighten later)
        let safety: [SafetySetting] = [
//            SafetySetting(category: .harassment, threshold: .blockNone),
//            SafetySetting(category: .hateSpeech, threshold: .blockNone),
//            SafetySetting(category: .sexuallyExplicit, threshold: .blockNone),
//            SafetySetting(category: .dangerousContent, threshold: .blockNone)
        ]

        if let systemInstruction {
            self.model = GenerativeModel(
                name: modelName,
                apiKey: apiKey,
                
                generationConfig: config,
                safetySettings: safety,
                systemInstruction: systemInstruction

            )
        } else {
            self.model = GenerativeModel(
                name: modelName,
                apiKey: apiKey,
                generationConfig: config,
                safetySettings: safety
            )
        }
    }

    /// Single-turn reply. (Easy to swap for your real multi-turn later.)
    func reply(to userText: String) -> AnyPublisher<String, Never> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let response = try await self.model.generateContent(userText)
                        let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        promise(.success(text?.isEmpty == false ? text! : "I couldn’t generate a reply."))
                    } catch {
                        // Map errors to a safe Never-failing publisher
                        promise(.success("Sorry, I ran into a problem reaching the assistant."))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
