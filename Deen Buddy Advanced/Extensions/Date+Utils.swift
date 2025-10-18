//
//  Date+Utils.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/18/25.
//

import Foundation
//

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var isFriday: Bool { Calendar.current.component(.weekday, from: self) == 6 } // Sun=1
}
