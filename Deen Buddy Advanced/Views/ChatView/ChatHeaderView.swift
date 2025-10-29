//
//  ChatHeaderView.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/6/25.
//

// Views/Chat/ChatHeaderView.swift
import SwiftUI

struct ChatHeaderView: View {
    var title: String
    var onBack: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.Chat.closeButton(for: colorScheme))
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .opacity(onBack == nil ? 0 : 1)

            Spacer()
            Text(title)
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(AppColors.Chat.headerTitle(for: colorScheme))
            Spacer()

            // placeholder to balance back button
            AppColors.Common.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.clear)
    }
}
