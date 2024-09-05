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

enum DayOfMonth: Equatable, Identifiable {
    case weekday(DayOfWeek)
    case day(Int)

    var id: String {
        let info: String
        switch self {
        case .weekday(let dayOfWeek):
            info = [
                "weekday: \(dayOfWeek.weekday.dateComponent)",
                dayOfWeek.weekNumber.flatMap({ "weekNumber: \($0)" })
            ]
                .compactMap({ $0 })
                .joined(separator: ", ")
        case .day(let dayNo):
            info = "day: \(dayNo)"
        }
        return "[\(info)]"
    }

    var title: String {
        switch self {
        case .weekday(let dayOfWeek):
            return dayOfWeek.standaloneText
        case .day(let dayNo):
            return String(localized: "Day %@", bundle: .core)
                .asFormat(for: dayNo.formatted(.number))
        }
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
            DayOfMonth.day(day),
            DayOfMonth.weekday(DayOfWeek(weekday, weekNumber: weekNumber))
        ]
    }
}
