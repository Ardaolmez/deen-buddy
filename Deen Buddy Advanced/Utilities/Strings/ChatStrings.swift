//
//  ChatStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Chat feature
//

import Foundation

private let table = "Chat"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct ChatStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var chatBoxPrompt: String { lang.getString("chatBoxPrompt", table: table) }
    static var todayChatBoxPrompt: String { lang.getString("todayChatBoxPrompt", table: table) }
    static var inputPlaceholder: String { lang.getString("inputPlaceholder", table: table) }
    static var inputPlaceholderShort: String { lang.getString("inputPlaceholderShort", table: table) }
    static var close: String { lang.getString("close", table: table) }
    static var botName: String { lang.getString("botName", table: table) }
    static var welcomeMessage: String { lang.getString("welcomeMessage", table: table) }

    // Loading
    static var loadingIndicator: String { lang.getString("loadingIndicator", table: table) }

    // Stop button
    static var stopButton: String { lang.getString("stopButton", table: table) }

    // Citation card (not localized - SF Symbol name)
    static let citationIconName = "book.closed.fill"
}
