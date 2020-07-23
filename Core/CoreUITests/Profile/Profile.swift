//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

enum Profile: String, ElementWrapper {
    case
        actAsUserButton,
        changeUserButton,
        colorOverlayToggle,
        developerMenuButton,
        filesButton,
        helpButton,
        logOutButton,
        settingsButton,
        showGradesToggle,
        userEmailLabel,
        userNameLabel,
        versionLabel,
        inboxButton

    static func ltiButton(domain: String, id: String) -> Element {
        return app.find(id: "Profile.lti.\(domain).\(id)")
    }

    static func close(file: StaticString = #file, line: UInt = #line) {
        Dashboard.profileButton.tapAt(.zero, file: file, line: line)
    }

    static func open() {
        // HACK: sometimes a11y stuff doesn't show up...
        if !Dashboard.profileButton.exists() {
            TabBar.calendarTab.tap()
            TabBar.dashboardTab.tap()
        }
        Dashboard.profileButton.tapUntil {
            Profile.userNameLabel.exists
        }
    }
}

enum ProfileSettings {
    static var profile: Element {
        return app.find(label: "Profile")
    }

    static var about: Element {
        return app.find(label: "About")
    }

    static var landingPage: Element {
        return app.find(label: "Landing Page")
    }

    static var notificationPreferences: Element {
        return app.find(label: "Notification Preferences")
    }
}

enum LandingPageCell: Int, ElementWrapper, CaseIterable {
    case dashboard
    case calendar
    case todo
    case notifications
    case inbox

    var element: Element {
        return ItemPickerItem(row: rawValue).element
    }

    var relatedTab: TabBar {
        switch self {
        case .dashboard:
            return TabBar.dashboardTab
        case .calendar:
            return TabBar.calendarTab
        case .todo:
            return TabBar.todoTab
        case .notifications:
            return TabBar.notificationsTab
        case .inbox:
            return TabBar.inboxTab
        }
    }
}
