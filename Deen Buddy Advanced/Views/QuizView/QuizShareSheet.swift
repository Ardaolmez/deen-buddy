//
//  QuizShareSheet.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/14/25.
//

// QuizShareSheet.swift
import UIKit

enum QuizShareSheet {
    static func present(text: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        root.present(vc, animated: true)
    }
}
