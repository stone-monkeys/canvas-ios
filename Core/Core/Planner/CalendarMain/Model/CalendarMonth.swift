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

struct CalendarMonth: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.components == rhs.components
    }

    let calendar: Calendar
    let startDate: Date
    let endDate: Date

    init(calendar: Calendar, date: Date) {
        self.calendar = calendar

        let interval = calendar.dateInterval(of: .month, for: date)
        let startDate = interval?.start ?? calendar.startOfDay(for: date)

        self.startDate = startDate
        self.endDate = interval?.end
            ?? calendar.date(byAdding: .month, value: 1, to: startDate)
            ?? startDate.addingTimeInterval(30 * 24 * 3600)
    }

    private var components: (month: Int, year: Int) {
        let month = calendar.component(.month, from: startDate)
        let year = calendar.component(.year, from: startDate)
        return (month, year)
    }

    var weeks: [CalendarWeek] {
        let (month, year) = components
        return (calendar.range(of: .weekOfMonth, in: .month, for: startDate) ?? .zero)
            .map {
                CalendarWeek(
                    calendar: calendar,
                    weekOfMonth: $0,
                    month: month,
                    year: year
                )
            }
    }

    var dateInterval: DateInterval {
        return DateInterval(start: startDate, end: endDate)
    }

    var weeksDateInterval: DateInterval? {
        guard let start = weeks.first?.dateInterval.start,
              let end = weeks.last?.dateInterval.end
        else { return nil }
        return DateInterval(start: start, end: end)
    }

    func containsDateInWeeks(_ edate: Date) -> Bool {
        guard let interval = weeksDateInterval else { return false }
        return interval.contains(edate)
    }

    func containsDate(_ edate: Date) -> Bool {
        return dateInterval.contains(edate)
    }
}
