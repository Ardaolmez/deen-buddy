//
//  QuoteLaunchView.swift
//  Deen Buddy Advanced
//
//  Launch screen showing random word of wisdom quote
//

import SwiftUI

struct QuoteLaunchView: View {
    @State private var quote: WordOfWisdom? = WordOfWisdom(
        quote: "The best revenge is to improve yourself.",
        author: "Ali ibn Abi Talib",
        explanation: "Focus on bettering yourself."
    )
    @State private var showShareSheet = false
    @State private var backgroundImageName: String = "bg_image_1"
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            // Background - randomly selected image, fallback to gradient
            Group {
                if let _ = UIImage(named: backgroundImageName) {
                    Image(backgroundImageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Fallback gradient background with Islamic design feel
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.3, blue: 0.4),
                            Color(red: 0.3, green: 0.4, blue: 0.5),
                            Color(red: 0.25, green: 0.35, blue: 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
            )

            // Content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                // App Title
                Text("Iman Buddy")
                    .font(.system(size: 34, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                Spacer()

                // Quote Content
                if let quote = quote {
                    VStack(spacing: 24) {
                        // Quote text with quotation marks
                        Text("\"\(quote.quote)\"")
                            .font(.system(size: 30, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                            .frame(maxWidth: UIScreen.main.bounds.width - 90) // Card max width
                            .italic()

                        // Author reference (formatted like the screenshot)
                        Text(quote.author.uppercased())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .tracking(2.0)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                    }
                } else {
                    // Loading state
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }

                Spacer()

                // Share Button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack(spacing: 8) {
                        Text("Share")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30)

                // Tap anywhere to continue
                Text("Or, tap anywhere to continue")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            loadRandomQuote()
            loadRandomBackground()
        }
        .onTapGesture {
            onContinue()
        }
        .sheet(isPresented: $showShareSheet) {
            if let quote = quote {
                ShareSheet(activityItems: [createShareText(quote)])
            }
        }
    }

    // MARK: - Helper Functions

    private func loadRandomQuote() {
        // Try to load quotes from JSON
        guard let url = Bundle.main.url(forResource: "word_of_wisdom", withExtension: "json") else {
            print("❌ Could not find word_of_wisdom.json in bundle")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not read word_of_wisdom.json")
            return
        }

        guard let quotes = try? JSONDecoder().decode([WordOfWisdom].self, from: data) else {
            print("❌ Could not decode word_of_wisdom.json")
            return
        }

        guard !quotes.isEmpty else {
            print("❌ word_of_wisdom.json is empty")
            return
        }

        // Successfully loaded, pick a random quote
        if let randomQuote = quotes.randomElement() {
            quote = randomQuote
            print("✅ Loaded random quote: '\(randomQuote.quote)' by \(randomQuote.author)")
        }
    }

    private func loadRandomBackground() {
        // Randomly select one of the 8 background images
        let randomIndex = Int.random(in: 1...8)
        backgroundImageName = "bg_image_\(randomIndex)"
        print("✅ Selected random background: \(backgroundImageName)")
    }

    private func createShareText(_ quote: WordOfWisdom) -> String {
        return """
        "\(quote.quote)"

        - \(quote.author)

        Shared from Iman Buddy
        """
    }
}

#Preview {
    QuoteLaunchView {
        print("Continue tapped")
    }
}
