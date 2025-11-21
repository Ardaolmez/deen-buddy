//
//  ExploreStrings.swift
//  Deen Buddy Advanced
//
//  Strings for Explore tab
//

import Foundation

private let table = "Explore"
private var lang: AppLanguageManager { AppLanguageManager.shared }

struct ExploreStrings {
    static var navigationTitle: String { lang.getString("navigationTitle", table: table) }
    static var comingSoon: String { lang.getString("comingSoon", table: table) }
    static var prophetStoriesComingSoon: String { lang.getString("prophetStoriesComingSoon", table: table) }
    static var view: String { lang.getString("view", table: table) }
    static var hijriDateTitle: String { lang.getString("hijriDateTitle", table: table) }
    static var hijriLocationUnavailable: String { lang.getString("hijriLocationUnavailable", table: table) }
    static var hijriLoading: String { lang.getString("hijriLoading", table: table) }
    static var hijriCalendarTitle: String { lang.getString("hijriCalendarTitle", table: table) }
    static var hijriCalendarSubtitle: String { lang.getString("hijriCalendarSubtitle", table: table) }
    static var hijriCalendarHint: String { lang.getString("hijriCalendarHint", table: table) }
    static var hijriCalendarHijriHeader: String { lang.getString("hijriCalendarHijriHeader", table: table) }
    static var hijriCalendarGregorianHeader: String { lang.getString("hijriCalendarGregorianHeader", table: table) }
    static var hijriCalendarSpecialDatesTitle: String { lang.getString("hijriCalendarSpecialDatesTitle", table: table) }
    static var hijriCalendarSpecialDatesPlaceholder: String { lang.getString("hijriCalendarSpecialDatesPlaceholder", table: table) }
    static var hijriCalendarSpecialDatesReset: String { lang.getString("hijriCalendarSpecialDatesReset", table: table) }
}
