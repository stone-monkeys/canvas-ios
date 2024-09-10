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

extension InstUI {

    public struct DropDownCell<Label: View, DropDown: View>: View {
        private let label: Label

        @ViewBuilder
        private let dropDown: (Binding<DropDownButtonState>) -> DropDown

        @Binding var state: DropDownButtonState

        public init(label: Label,
                    state: Binding<DropDownButtonState>,
                    @ViewBuilder dropDown: @escaping (Binding<DropDownButtonState>) -> DropDown) {
            self.label = label
            self._state = state
            self.dropDown = dropDown
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    label.textStyle(.cellLabel)
                    Spacer()
                    dropDown($state)
                }
                .paddingStyle(set: .standardCell)
                InstUI.Divider()
            }
        }
    }
}

extension InstUI.DropDownCell {

    public init<Value>(
        label: Label,
        state: Binding<DropDownButtonState>,
        @ViewBuilder value: @escaping () -> Value
    ) where Value: View, DropDown == DropDownButton<Value> {

        self.init(
            label: label,
            state: state,
            dropDown: { stateBinding in
                DropDownButton(state: stateBinding, label: value)
            }
        )
    }
}

#if DEBUG

#Preview {
    InstUI.DropDownCell(label: Text(verbatim: "Repeats On"),
                        state: .constant(DropDownButtonState()),
                        value: { Text(verbatim: "Value") })
}

#endif
