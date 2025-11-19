//
//  KeyboardPublisher.swift
//  Deen Buddy Advanced
//
//  Created on 19/11/2025
//

import Combine
import UIKit

extension Publishers {
    /// Publisher that emits keyboard height changes
    /// Emits the keyboard height when it appears and 0 when it disappears
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
