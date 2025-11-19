//
//  KeyboardAdaptive.swift
//  Deen Buddy Advanced
//
//  Created on 19/11/2025
//

import SwiftUI
import Combine

/// ViewModifier that adds dynamic padding when keyboard appears/disappears
/// Prevents keyboard from covering content by pushing views upward
/// Uses spring animation to match iOS keyboard's CASpringAnimation
struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, max(0, keyboardHeight - geometry.safeAreaInsets.bottom))
                .onReceive(Publishers.keyboardHeight) { height in
                    // Match iOS keyboard spring animation: mass=3, stiffness=1000, damping=500
                    withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 0)) {
                        keyboardHeight = height
                    }
                }
        }
    }
}

extension View {
    /// Applies keyboard-adaptive padding to prevent keyboard from covering content
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}
