//
//  QuizResultView.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

import SwiftUI

// QuizResultView.swift
import SwiftUI

struct QuizResultView: View {
    let score: Int
    let total: Int
    let gradeText: String
    let onShare: () -> Void
    let onDone: () -> Void
    let onRetry: () -> Void

    private var percent: Double { total > 0 ? Double(score)/Double(total) : 0 }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button {
                    onDone()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
                Spacer()
                Text("Daily Quiz")
                    .font(.system(.title3, design: .serif).weight(.semibold))
                Spacer()
                // spacer to balance
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal)

            // Progress bar
            Capsule()
                .fill(Color.green.opacity(0.25))
                .frame(height: 6)
                .overlay(
                    GeometryReader { geo in
                        Capsule()
                            .fill(Color.green)
                            .frame(width: geo.size.width * percent)
                    }
                )
                .padding(.horizontal)

            // Card
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemGray6))
                VStack(spacing: 18) {
                    // Circular ring
                    ProgressRing(progress: percent)
                        .frame(width: 160, height: 160)
                        .padding(.top, 16)

                    Text("\(score)/\(total)")
                        .font(.system(size: 24, weight: .bold, design: .serif))

                    Text("Your Iman:")
                        .font(.system(.title3, design: .serif).weight(.semibold))
                        .padding(.top, 8)

                    Text(gradeText)
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Button {
                            onRetry()
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }

                        Button {
                            onShare()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 8)
                }
                .padding()
            }
            .padding(.horizontal)

            // Footer note
            Text("Deen Buddy will tailor custom quizzes for you each day based on your knowledge level. Keep going to steadily strengthen your Iman.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

