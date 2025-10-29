//
//  FeedbackPopupView.swift
//  Deen Buddy Advanced
//
//  Feedback popup for user suggestions
//

import SwiftUI
import UIKit

struct FeedbackPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccessMessage: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header text
                VStack(alignment: .leading, spacing: 8) {
                    Text("We'd love to hear from you!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.Common.primary)

                    Text("Share your suggestions, ideas, or feedback to help us improve the app.")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.Common.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

                // Text editor for feedback
                ZStack(alignment: .topLeading) {
                    if feedbackText.isEmpty {
                        Text("Type your suggestion here...")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.Common.secondary.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $feedbackText)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.Common.primary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .padding(4)
                }
                .background(AppColors.Today.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.Chat.boxBorder, lineWidth: 1)
                )

                // Success message
                if showSuccessMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.Feedback.successIcon)
                        Text(AppStrings.today.feedbackThankYou)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.Feedback.successText)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppColors.Feedback.successBackground)
                    .cornerRadius(8)
                }

                // Error message
                if showErrorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppColors.Feedback.errorIcon)
                        Text(errorMessage.isEmpty ? AppStrings.today.feedbackError : errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.Feedback.errorText)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppColors.Feedback.errorBackground)
                    .cornerRadius(8)
                }

                Spacer()

                // Submit button
                Button(action: {
                    submitFeedback()
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                            Text("Submit Feedback")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColors.Common.secondary.opacity(0.3) : AppColors.Today.dailyQuizButton)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
            }
            .padding()
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        showErrorMessage = false
        showSuccessMessage = false

        // FormBold endpoint
        let url = URL(string: "https://formbold.com/s/oeDBj")!

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Get device info
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        // Prepare the data
        let feedbackData: [String: Any] = [
            "message": feedbackText,
            "app": "Deen Buddy Advanced",
            "platform": "iOS",
            "device": device.model,
            "ios_version": device.systemVersion,
            "app_version": "\(appVersion) (\(buildNumber))",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)
        } catch {
            print("Error serializing feedback data: \(error)")
            isSubmitting = false
            showErrorMessage = true
            errorMessage = "Failed to prepare feedback data"
            return
        }

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error submitting feedback: \(error)")
                    isSubmitting = false
                    showErrorMessage = true
                    errorMessage = "Network error. Please check your connection."
                    return
                }

                // Check if submission was successful
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    // Success
                    isSubmitting = false
                    showSuccessMessage = true
                    feedbackText = ""

                    // Auto-dismiss after showing success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        dismiss()
                    }
                } else {
                    // Server error
                    print("Server error submitting feedback")
                    isSubmitting = false
                    showErrorMessage = true
                    errorMessage = "Server error. Please try again later."
                }
            }
        }.resume()
    }
}

#Preview {
    FeedbackPopupView()
}