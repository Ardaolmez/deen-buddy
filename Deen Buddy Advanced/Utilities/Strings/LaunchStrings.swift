//
//  LaunchStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Launch Screen
//

import Foundation

private let table = "Launch"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct LaunchStrings {
    static var share: String { lang.getString("share", table: table) }
    static var tapToContinue: String { lang.getString("tapToContinue", table: table) }
    static var sharedFrom: String { lang.getString("sharedFrom", table: table) }
}
