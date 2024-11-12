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

public struct CourseSmartSearchHelpView: View {
    @Environment(\.courseSmartSearchContext) private var searchContext
    @Environment(\.viewController) private var controller

    public init() { }

    public var body: some View {
        VStack {
            Text(verbatim: ".. Help Content ..")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    controller.value.dismiss(animated: true)
                }
                .tint(contextColor)
            }
        }
    }

    private var contextColor: Color {
        return Color(uiColor: searchContext.info.color ?? .textDarkest)
    }
}
