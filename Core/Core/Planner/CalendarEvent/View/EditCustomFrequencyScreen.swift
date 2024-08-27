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

import SwiftUI

struct EditCustomFrequencyScreen: View, ScreenViewTrackable {
    private enum FocusedInput {
        case frequencyInterval
        case repeatsOn
        case endRepeat
    }
    @FocusState private var focusedInput: FocusedInput?

    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditCustomFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @State private var weekDayDropDownState = DropDownButtonState()

    @State var selection: [Int] = [0, 0]

    @State var isOccurenceDialogPresented: Bool = false
    @State var weekDays: [Weekday] = []
    @State var endMode: RecurrenceEndMode?
    @State var endDate: Date? = Clock.now
    @State var occurencesCount: Int = 0

    private var selectedFrequency: RecurrenceFrequency {
        return RecurrenceFrequency.allCases[selection[1]]
    }

    init(viewModel: EditCustomFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {

                MultiPickerView(
                    content: [
                        (1 ... 400).map({ String($0) }),
                        RecurrenceFrequency.allCases.map { $0.selectionText }
                    ],
                    widths: [3, 7],
                    alignments: [.right, .left],
                    selections: $selection
                )
                .frame(maxWidth: .infinity)

                if selectedFrequency != .daily {
                    weekDaysCell
                }

                endModeCell

                if let endMode {
                    cellForEndMode(endMode)
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            trailing: .init(
                isAvailableOffline: false,
                title: viewModel.doneButtonTitle,
                action: {
                    viewModel.didTapDone.send()
                }
            )
        )
        .dropDownDetails(state: $weekDayDropDownState) {
            WeekDaysSelectionListView(selection: $weekDays)
        }

    }

    private var weekDaysCell: some View {
        InstUI.DropDownCell(
            label: Text("Repeats on", bundle: .core),
            state: $weekDayDropDownState) {

                if weekDays.isEmpty {
                    DropDownPromptLabel()
                } else {

                    HStack(spacing: 8) {
                        ForEach(weekDays.selectionTexts, id: \.self) { day in
                            DropDownSelectedValueView(text: day)
                        }
                    }
                }
            }
    }

    private var endModeCell: some View {
        InstUI.PickerCell(
            label: Text("End Repeat", bundle: .core),
            content: {
                ForEach(RecurrenceEndMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode as RecurrenceEndMode?)
                }
            },
            selection: $endMode,
            placeholder: "Not selected"
        )
    }

    private var endDateCell: some View {
        InstUI.DatePickerCell(
            label: Text("End date", bundle: .core),
            date: $endDate,
            mode: .dateOnly,
            defaultDate: .now,
            validFrom: endDate.flatMap({ min($0, .now) }) ?? .now,
            isClearable: false
        )
    }

    private var endOccurencesCountCell: some View {
        InstUI.LabelValueCell(
            label: Text("Number of Occurences", bundle: .core),
            value: occurencesCount.formatted(.number), 
            equalWidth: false) {
                isOccurenceDialogPresented = true
            }
    }

    @ViewBuilder
    private func cellForEndMode(_ endMode: RecurrenceEndMode) -> some View {
        switch endMode {
        case .onDate:
            endDateCell
        case .afterOccurences:
            endOccurencesCountCell
        }
    }
}

enum RecurrenceEndMode: Equatable, CaseIterable {
    case onDate
    case afterOccurences

    var title: String {
        switch self {
        case .onDate:
            return "On date".localized()
        case .afterOccurences:
            return "After Occurences".localized()
        }
    }
}

#if DEBUG

#Preview {

    Rectangle()
        .sheet(isPresented: .constant(true), content: {
            NavigationView {
                EditCustomFrequencyScreen(
                    viewModel:
                        EditCustomFrequencyViewModel(
                            rule: nil,
                            proposedDate: Date(),
                            completion: { rule in
                                print("Selected rule:")
                                print(rule?.rruleDescription)
                            })
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        })
}

#Preview {

    EditCustomFrequencyScreen(
        viewModel:
            EditCustomFrequencyViewModel(
                rule: nil,
                proposedDate: Date(),
                completion: { rule in
                    print("Selected rule:")
                    print(rule?.rruleDescription)
                })
    )
}

#endif
