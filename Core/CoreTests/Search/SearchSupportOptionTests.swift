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
import TestsFoundation
import SwiftUI
@testable import Core

class SearchSupportOptionTests: CoreTestCase {

    func test_sheet_action() throws {
        // Given
        let action = SearchSupportSheet(content: Text(".. Sheet Content .."))
        let startVC = UIViewController()

        // When
        action.triggered(with: router, from: startVC)

        // Then
        let presented = router.presented as? CoreHostingController<Text>
        XCTAssertNotNil(presented)
    }

    func test_simple_action() throws {
        // Given
        var actionCalled = false
        let action = SearchSupportTrigger({ actionCalled = true })

        // When
        action.triggered(with: router, from: UIViewController())

        // Then
        XCTAssertTrue(actionCalled)
    }
}
