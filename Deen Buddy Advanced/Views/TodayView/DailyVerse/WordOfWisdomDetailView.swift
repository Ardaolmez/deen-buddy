//
//  WordOfWisdomDetailView.swift
//  Deen Buddy Advanced
//
//  Full-screen modal displaying Word of Wisdom (daily verse) content
//

import SwiftUI

struct WordOfWisdomDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let verse: Verse
    let surahName: String
    let reference: String

    @State private var showChat = false
    @State private var showShareSheet = false

    // Random background image for verses
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
                                    Image(systemName: "book.closed.fill")
                                        .font(.system(size: 16))
                                    Text("WORD OF WISDOM")
                                        .font(.system(size: 13, weight: .bold))
                                        .tracking(1)
                                }
                                .foregroundColor(.white)
                                .padding(.top, 8)

                                // Reference
                                Text(reference)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color.orange)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)

                                // Arabic Text
                                Text(verse.text)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(12)
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .padding(.top, 12)

                                // Translation Label and Text
                                if let translation = verse.translation {
                                    Text("Translation")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(Color.orange)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)

                                    Text(translation)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white.opacity(0.95))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(6)
                                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                                }

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
        var message = "I would like to learn more about this verse from the Quran"
        message += " (\(reference)).\n\n"

        if let translation = verse.translation {
            message += "The translation is: \"\(translation)\"\n\n"
        }

        message += "Please tell me about:\n"
        message += "• Its context and revelation\n"
        message += "• The deeper meaning and lessons\n"
        message += "• How to apply this wisdom in daily life\n"
        message += "• Related verses or teachings"

        return message
    }

    private func generateShareText() -> String {
        var shareText = "Word of Wisdom - \(reference)\n\n"
        shareText += verse.text

        if let translation = verse.translation {
            shareText += "\n\n\(translation)"
        }

        shareText += "\n\nShared from Deen Buddy"
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
        verse: Verse(
            id: 45,
            text: "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ",
            translation: "And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive to Allah."
        ),
        surahName: "Al-Baqarah",
        reference: "Surah Al-Baqarah 2:45"
    )
}
