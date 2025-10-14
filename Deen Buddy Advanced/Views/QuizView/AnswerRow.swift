//
//  AnswerRow.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/12/25.
//
// Views/AnswerRow.swift
import SwiftUI
// Reusable row (with green/red highlight and lock after pick)
struct AnswerRow: View {
    let text: String
    let state: QuizViewModel.AnswerState
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(text).foregroundColor(.primary)
                Spacer()
                switch state {
                case .correctHighlight:
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                case .wrongHighlight:
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                case .neutral:
                    EmptyView()
                }
            }
            .padding()
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
        case .neutral:          return Color(.systemGray6)
        case .correctHighlight: return Color.green.opacity(0.15)
        case .wrongHighlight:   return Color.red.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch state {
        case .neutral:          return .clear
        case .correctHighlight: return .green
        case .wrongHighlight:   return .red
        }
    }
}
