//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct DayOfMonth: Equatable, Identifiable {
    var id: String {
        return [
            "weekday: \(weekday?.weekday.dateComponent ?? 0)",
            "weekNumber: \(weekday?.weekNumber ?? 0)",
            "day: \(day ?? 0)"
        ].joined(separator: ", ")
    }

    var weekday: DayOfWeek?
    var day: Int?

    init(weekday: DayOfWeek) {
        self.weekday = weekday
        self.day = nil
    }

    init(day: Int) {
        self.weekday = nil
        self.day = day
    }
}

extension Array where Element == DayOfMonth {

    static func options(for date: Date, in calendar: Calendar = Cal.currentCalendar) -> Self {
        let comps = calendar.dateComponents(
            [.calendar, .day, .weekday, .weekdayOrdinal, .month, .year],
            from: date
        )

        let weekday = Weekday(component: comps.weekday!) ?? .sunday
        let weekNumber = comps.weekdayOrdinal!
        let day = comps.day!

        return [
            DayOfMonth(day: day),
            DayOfMonth(weekday: DayOfWeek(weekday, weekNumber: weekNumber))
        ]
    }
}

extension DayOfMonth {

    var title: String {

        if let day {
            return String(format: "Day %@", day.formatted(.number))
        }

        if let weekday {
            let format = weekday.weekNumber.standaloneFormat
            return String(format: format, weekday.weekday.text)
        }

        return "[Invalid Day]"
    }
}

// MARK: - Utils

extension DateFormatter {
    private static let _default = DateFormatter()
    static func `default`(format: String, calendar: Calendar = Cal.currentCalendar) -> DateFormatter {
        _default.calendar = calendar
        _default.dateFormat = format
        return _default
    }
}

extension Date {

    func formatted(format: String, calendar: Calendar = Cal.currentCalendar) -> String {
        return DateFormatter
            .default(format: format, calendar: calendar)
            .string(from: self)
    }

    #if DEBUG
    init?(_ stringValue: String, format: String) {
        guard let parsed = DateFormatter
            .default(format: format)
            .date(from: stringValue) else { return nil }
        self = parsed
    }
    #endif
}
