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

import XCTest
@testable import Core

final class FrequencyPresetTests: CoreTestCase {

    func test_non_calculative() {
        // Given
        let rule = RecurrenceRule(recurrenceWith: .daily,
                                  interval: 2,
                                  end: RecurrenceEnd(occurrenceCount: 33))

        // Then
        XCTAssertNil(FrequencyPreset.noRepeat.rule(given: .now))
        XCTAssertEqual(FrequencyPreset.custom(rule).rule(given: .now), rule)
        XCTAssertEqual(FrequencyPreset.selected(title: "", rule: rule).rule(given: .now), rule)

        // Given
        let customPreset = FrequencyPreset.custom(rule)

        // Then
        XCTAssertEqual(customPreset.isCustom, true)
        XCTAssertEqual(FrequencyPreset.calculativePresets.contains(where: { $0.isCustom }), false)
        XCTAssertEqual(FrequencyPreset.selected(title: "", rule: rule).isCustom, false)
        XCTAssertEqual(FrequencyPreset.noRepeat.isCustom, false)
    }

    func test_calculative() {
        // Given
        let date = TestConstants.date

        for useCase in TestConstants.useCases {
            // When
            let rule = useCase.preset.rule(given: date)

            // Then
            XCTAssertEqual(useCase.expected, rule)
        }
    }

    func test_selected_frequency_preset() {
        // Given
        let date = Date.make(year: 2024, month: 4, day: 4)
        let event = CalendarEvent(context: databaseClient)
        event.startAt = date

        for useCase in TestConstants.useCases {
            // When
            event.repetitionRule = useCase.raw
            event.seriesInNaturalLanguage = nil

            // Then
            XCTAssertEqual(event.frequencyPreset, useCase.preset)
            XCTAssertEqual(event.frequencySelection?.value, useCase.expected)
        }

        // Given - Selected case
        let randomRule = RecurrenceRule(
            recurrenceWith: .weekly,
            interval: 3,
            daysOfTheWeek: [DayOfWeek(.sunday), DayOfWeek(.wednesday), DayOfWeek(.thursday)],
            end: RecurrenceEnd(occurrenceCount: 33)
        )

        // When
        event.repetitionRule = randomRule.rruleDescription
        event.seriesInNaturalLanguage = "Weekly on Sunday, Wednesday & Thursday, 33 times"

        XCTAssertEqual(
            event.frequencyPreset,
            .selected(title: event.seriesInNaturalLanguage, rule: randomRule)
        )

        XCTAssertEqual(
            event.frequencySelection?.preset,
            .selected(title: event.seriesInNaturalLanguage, rule: randomRule)
        )

        XCTAssertEqual(event.frequencySelection?.title, event.seriesInNaturalLanguage)
        XCTAssertEqual(event.frequencySelection?.value, randomRule)
    }
}

private enum TestConstants {

    struct UseCase {
        let preset: FrequencyPreset
        let raw: String
        let expected: RecurrenceRule
    }

    static let date = Date.make(year: 2024, month: 4, day: 4)

    static let useCases: [UseCase] = [
        // Daily
        UseCase(
            preset: .daily,
            raw: "FREQ=DAILY;INTERVAL=1;COUNT=365",
            expected: RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: RecurrenceEnd(occurrenceCount: 365)
            )
        ),
        UseCase(
            preset: .weeklyOnThatDay,
            raw: "FREQ=WEEKLY;INTERVAL=1;BYDAY=\(date.weekday.rawValue);COUNT=52",
            expected: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [
                    DayOfWeek(date.weekday)
                ],
                end: RecurrenceEnd(occurrenceCount: 52)
            )
        ),
        UseCase(
            preset: .monthlyOnThatWeekday,
            raw: "FREQ=MONTHLY;INTERVAL=1;BYDAY=\(date.monthWeekday.rruleString);COUNT=12",
            expected: RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                daysOfTheWeek: [
                    date.monthWeekday
                ],
                end: RecurrenceEnd(occurrenceCount: 12)
            )
        ),
        UseCase(
            preset: .yearlyOnThatMonth,
            raw: "FREQ=YEARLY;INTERVAL=1;BYMONTH=\(date.month);BYMONTHDAY=\(date.monthDay);COUNT=5",
            expected: RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                daysOfTheMonth: [date.monthDay],
                monthsOfTheYear: [date.month],
                end: RecurrenceEnd(occurrenceCount: 5)
            )
        ),
        UseCase(
            preset: .everyWeekday,
            raw: "FREQ=WEEKLY;INTERVAL=1;BYDAY=\(Weekday.weekDays.map { $0.rawValue }.joined(separator: ","));COUNT=260",
            expected: RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: Weekday.weekDays.map({ DayOfWeek($0) }),
                end: RecurrenceEnd(occurrenceCount: 260)
            )
        )
    ]
}
