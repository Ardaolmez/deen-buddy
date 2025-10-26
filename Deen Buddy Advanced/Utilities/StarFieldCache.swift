//
//  StarFieldCache.swift
//  Deen Buddy Advanced
//
//  Pre-computed star positions for StarryNightBackground
//  Improves performance by avoiding random generation on every render
//

import SwiftUI

/// Pre-computed star positions for better performance
class StarFieldCache {
    static let shared = StarFieldCache()

    let stars: [Star]

    struct Star {
        let x: CGFloat  // Position as ratio (0-1)
        let y: CGFloat
        let size: CGFloat
        let brightness: Double
    }

    private init() {
        self.stars = (0..<80).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                brightness: Double.random(in: 0.6...1.0)
            )
        }
    }
}
