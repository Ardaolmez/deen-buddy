//
//  Secrets.swift
//  Deen Buddy
//
//  Created by Rana Shaheryar on 10/7/25.
//

import Foundation

enum Secrets {
    static var geminiAPIKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String) ?? ""
    }
}
