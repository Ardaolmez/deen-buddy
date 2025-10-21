//
//  AnswerRow.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/12/25.
//
// Views/AnswerRow.swift
import SwiftUI
// Answer button with color-based feedback
struct AnswerRow: View {
    let text: String
    let state: QuizViewModel.AnswerState
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .foregroundColor(AppColors.Quiz.answerText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .frame(height: 80)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: state == .neutral ? 0 : 1)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isLocked || state != .neutral) // tap only when not locked and still neutral
        .padding(.horizontal)
    }

    private var backgroundColor: Color {
        switch state {
        case .neutral:          return AppColors.Quiz.answerNeutralBackground
        case .correctHighlight: return AppColors.Quiz.answerCorrectBackground
        case .wrongHighlight:   return AppColors.Quiz.answerWrongBackground
        }
    }

    private var borderColor: Color {
        switch state {
        case .neutral:          return AppColors.Quiz.answerNeutralBorder
        case .correctHighlight: return AppColors.Quiz.answerCorrectBorder
        case .wrongHighlight:   return AppColors.Quiz.answerWrongBorder
        }
    }
}
