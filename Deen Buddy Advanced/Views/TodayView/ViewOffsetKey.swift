//
//  ViewOffsetKey.swift
//  Deen Buddy Advanced
//
//  Preference key for tracking view position in scroll view
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
