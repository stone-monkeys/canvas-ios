//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import TestsFoundation

class NotificationsTests: E2ETestCase {
    func testNotifications() {
        // MARK: Seed the usual stuff with a course invitation, an event, a submitted assignment
        let student = seeder.createUser()
        let course1 = seeder.createCourse()
        let course2 = seeder.createCourse()
        seeder.enrollStudent(student, in: course1)
        let courseInvitation = seeder.enrollStudent(student, in: course2, state: .invited)
        let event = CalendarHelper.createCalendarEvent(course: course1)
        let assignment = AssignmentsHelper.createAssignment(course: course1, gradingType: .letter_grade)
        let submission = GradesHelper.createSubmission(as: student, in: course1, for: assignment)

        // MARK: Get the user logged in and check course invitation notification
        logInDSUser(student)

        let youHaveBeenInvited = NotificationsHelper.CourseInvitation.youHaveBeenInvited.waitUntil(.visible)
        let courseInvitationDecline = NotificationsHelper.CourseInvitation.declineButton(enrollment: courseInvitation).waitUntil(.visible)
        let courseInvitationAccept = NotificationsHelper.CourseInvitation.acceptButton(enrollment: courseInvitation).waitUntil(.visible)
        let courseCard1 = DashboardHelper.courseCard(course: course1).waitUntil(.visible)
        let courseCard2 = DashboardHelper.courseCard(course: course2).waitUntil(.visible)
        XCTAssertTrue(youHaveBeenInvited.isVisible)
        XCTAssertTrue(courseInvitationDecline.isVisible)
        XCTAssertTrue(courseInvitationAccept.isVisible)
        XCTAssertTrue(courseCard1.isVisible)
        XCTAssertTrue(courseCard2.isVisible)

        // MARK: Decline course invitation and check if course card vanishes
        courseInvitationDecline.hit()
        XCTAssertTrue(courseCard2.actionUntilElementCondition(action: .pullToRefresh, condition: .vanish))

        // MARK: Get submission graded, check notification
        let notificationsTab = NotificationsHelper.TabBar.notificationsTab.waitUntil(.visible)
        XCTAssertTrue(notificationsTab.isVisible)

        notificationsTab.hit()

        GradesHelper.gradeSubmission(grade: "A", in: course1, for: assignment, of: student)
        print("ASD")
    }
}
