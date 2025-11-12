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
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                        } else {
                            // Fallback gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.Today.fallbackGradientStart,
                                    AppColors.Today.fallbackGradientMid,
                                    AppColors.Today.fallbackGradientEnd
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
                        }

                        // Dark overlay to make text more prominent
                        AppColors.Today.darkOverlay
                            .ignoresSafeArea()

                        // Additional gradient for depth
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.Today.gradientOverlayLight,
                                AppColors.Today.gradientOverlayMedium,
                                AppColors.Today.gradientOverlayDark
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

                                // Opening quote mark - decorative
                                Text("\u{201C}")
                                    .font(.system(size: min(geometry.size.width * 0.15, 48), weight: .bold))
                                    .foregroundColor(AppColors.Today.wisdomQuoteMark)
                                    .padding(.top, 16)

                                // Quote Text
                                Text(wisdom.quote)
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.Today.wisdomQuoteText)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(12)
                                    .minimumScaleFactor(0.7)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)

                                // Closing quote mark - decorative
                                Text("\u{201D}")
                                    .font(.system(size: min(geometry.size.width * 0.15, 48), weight: .bold))
                                    .foregroundColor(AppColors.Today.wisdomQuoteMark)

                                // Author with decorative elements
                                VStack(spacing: 12) {
                                    Rectangle()
                                        .fill(AppColors.Today.wisdomAuthorLine)
                                        .frame(width: 60, height: 3)
                                        .cornerRadius(1.5)

                                    Text("- \(wisdom.author)")
                                        .font(.system(size: min(geometry.size.width * 0.05, 20), weight: .medium, design: .serif))
                                        .foregroundColor(AppColors.Today.wisdomAuthorText)
                                        .italic()
                                        .minimumScaleFactor(0.8)
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .padding(.top, 8)

                                // Explanation Section
                                VStack(alignment: .leading, spacing: 12) {
                                    // Divider line
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [
                                                AppColors.Today.wisdomDividerStart,
                                                AppColors.Today.wisdomDividerMid,
                                                AppColors.Today.wisdomDividerStart
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
                                            .foregroundColor(AppColors.Today.wisdomUnderstandingIcon)

                                        Text(TodayStrings.wisdomUnderstanding)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(AppColors.Today.wisdomUnderstandingLabel)
                                    }

                                    // Explanation Text
                                    Text(wisdom.explanation)
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineSpacing(8)
                                        .minimumScaleFactor(0.85)
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .padding(.top, 12)

                                // Bottom padding for scroll
                                Spacer()
                                    .frame(height: 40)
                            }
                            .padding(.horizontal, 24)
                            .frame(maxWidth: geometry.size.width)
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
                                            .fill(AppColors.Today.buttonWhiteOverlay)
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
                                    Text(TodayStrings.activityChatToLearnMore)
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.Today.buttonWhiteOverlay)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(TodayStrings.wisdomShareTitle)
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
                            .background(Circle().fill(AppColors.Today.buttonWhiteOverlay))
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
        var message = "\(TodayStrings.wisdomChatPromptPrefix) \(wisdom.author).\n\n"
        message += "\(TodayStrings.wisdomChatQuoteLabel) \"\(wisdom.quote)\"\n\n"
        message += "\(TodayStrings.wisdomChatExplanationLabel) \"\(wisdom.explanation)\"\n\n"
        message += TodayStrings.wisdomChatRequestDetails

        return message
    }

    private func generateShareText() -> String {
        var shareText = "\(TodayStrings.wisdomShareTitle)\n\n"
        shareText += "\"\(wisdom.quote)\"\n\n"
        shareText += "- \(wisdom.author)\n\n"
        shareText += "\(wisdom.explanation)\n\n"
        shareText += TodayStrings.wisdomShareFooter
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
