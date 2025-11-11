//
//  WordOfWisdomDetailView.swift
//  Deen Buddy Advanced
//
//  Full-screen modal displaying Word of Wisdom content
//

import SwiftUI

struct WordOfWisdomDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let wisdom: WordOfWisdom

    @State private var showChat = false
    @State private var showShareSheet = false

    // Random background image for wisdom cards
    private var backgroundImageName: String {
        BackgroundImageManager.shared.getRandomImage(for: .verse)
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background - Beautiful Islamic artwork
                    ZStack {
                        // Base background color
                        AppColors.Today.cardBackground
                            .ignoresSafeArea()

                        // Random background image
                        if let image = UIImage(named: backgroundImageName) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                        } else {
                            // Fallback gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.45, blue: 0.5),
                                    Color(red: 0.3, green: 0.4, blue: 0.45),
                                    Color(red: 0.2, green: 0.3, blue: 0.35)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
                        }

                        // Dark overlay to make text more prominent
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()

                        // Additional gradient for depth
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    }

                    VStack(spacing: 0) {
                        // Scrollable Content Area
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                // Top padding
                                Spacer()
                                    .frame(height: 20)

                                // Word of Wisdom badge
                                HStack(spacing: 8) {
                                    Image(systemName: "quote.bubble.fill")
                                        .font(.system(size: 16))
                                    Text("WORD OF WISDOM")
                                        .font(.system(size: 13, weight: .bold))
                                        .tracking(1)
                                }
                                .foregroundColor(.white)
                                .padding(.top, 8)

                                // Opening quote mark - decorative
                                Text("\u{201C}")
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundColor(Color.orange.opacity(0.3))
                                    .padding(.top, 16)

                                // Quote Text
                                Text(wisdom.quote)
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(12)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal, 8)

                                // Closing quote mark - decorative
                                Text("\u{201D}")
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundColor(Color.orange.opacity(0.3))

                                // Author with decorative elements
                                VStack(spacing: 12) {
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.6))
                                        .frame(width: 60, height: 3)
                                        .cornerRadius(1.5)

                                    Text("- \(wisdom.author)")
                                        .font(.system(size: 20, weight: .medium, design: .serif))
                                        .foregroundColor(Color.orange)
                                        .italic()
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .padding(.top, 8)

                                // Explanation Section
                                VStack(alignment: .leading, spacing: 12) {
                                    // Divider line
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.0),
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.0)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(height: 1)
                                        .padding(.vertical, 16)

                                    // Explanation Label
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.yellow)

                                        Text("Understanding")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(Color.yellow)
                                    }

                                    // Explanation Text
                                    Text(wisdom.explanation)
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineSpacing(8)
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 12)

                                // Bottom padding for scroll
                                Spacer()
                                    .frame(height: 40)
                            }
                            .padding(.horizontal, 24)
                        }

                        // Action Buttons Section at the bottom
                        HStack(spacing: 12) {
                            // Share button
                            Button(action: {
                                showShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.2))
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(.ultraThinMaterial)
                                            )
                                    )
                            }

                            // Chat to learn more button
                            Button(action: {
                                showChat = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 14))
                                    Text("Chat to learn more")
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.2))
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Word of Wisdom")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showChat) {
                ChatView(initialMessage: generateChatMessage())
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [generateShareText()])
            }
        }
    }

    // MARK: - Helper Functions

    private func generateChatMessage() -> String {
        var message = "I would like to learn more about this wisdom quote by \(wisdom.author).\n\n"
        message += "Quote: \"\(wisdom.quote)\"\n\n"
        message += "The explanation given is: \"\(wisdom.explanation)\"\n\n"
        message += "Please tell me more about:\n"
        message += "• The deeper meaning and context of this wisdom\n"
        message += "• How to apply this in daily life\n"
        message += "• Related teachings from Islam\n"
        message += "• Practical examples of living by this principle"

        return message
    }

    private func generateShareText() -> String {
        var shareText = "Word of Wisdom\n\n"
        shareText += "\"\(wisdom.quote)\"\n\n"
        shareText += "- \(wisdom.author)\n\n"
        shareText += "\(wisdom.explanation)\n\n"
        shareText += "Shared from Deen Buddy"
        return shareText
    }
}

// MARK: - ShareSheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    WordOfWisdomDetailView(
        wisdom: WordOfWisdom(
            quote: "The best revenge is to improve yourself.",
            author: "Ali ibn Abi Talib",
            explanation: "Instead of seeking to harm those who hurt you or holding onto resentment, focus your energy on bettering yourself - your character, your actions, your faith. Self-improvement becomes the most dignified response."
        )
    )
}
