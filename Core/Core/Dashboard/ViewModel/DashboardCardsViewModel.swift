//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import SwiftUI
import WatchConnectivity

class DashboardCardsViewModel: NSObject, ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
        case error(String)
    }

    @Published public private(set) var state = ViewModelState<[DashboardCard]>.loading
    @Published public private(set) var shouldShowSettingsButton = false
    private let env = AppEnvironment.shared
    private lazy var cards: Store<GetDashboardCards> = env.subscribe(GetDashboardCards()) { [weak self] in
        self?.update()
    }
    private lazy var courses = env.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
        self?.update()
    }
    private let showOnlyTeacherEnrollment: Bool
    private var needsRefresh = false
    private var subscriptions = Set<AnyCancellable>()
    private let courseSectionStatus = CourseSectionStatus()
    private let session: WCSession = .default

    public init(showOnlyTeacherEnrollment: Bool) {
        self.showOnlyTeacherEnrollment = showOnlyTeacherEnrollment
        super.init()
        setupWatchConnectivity()
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.favoritesDidChange() }
            .store(in: &subscriptions)
    }

    func setupWatchConnectivity() {
        self.session.delegate = self
        session.activate()
        session.delegate = self
    }

    public func refresh(onComplete: (() -> Void)? = nil) {
        needsRefresh = false
        courses.exhaust(force: true)
        cards.refresh(force: true) { [weak self] _ in
            onComplete?()
            guard let self = self else { return }
            if self.needsRefresh { self.refresh() }
        }

        courseSectionStatus.refresh { [weak self] in
            self?.update()
        }
    }

    private func favoritesDidChange() {
        if cards.pending {
            needsRefresh = true
        } else {
            refresh()
        }
    }

    private func update() {
        guard cards.requested, !cards.pending, !courseSectionStatus.isUpdatePending, courses.requested, !courses.pending, !courses.hasNextPage else { return }

        guard cards.state != .error else {
            state = .error(NSLocalizedString("Something went wrong", comment: ""))
            return
        }

        let cards = filteredCards()
        send(courses: cards.compactMap { $0.course })
        state = cards.isEmpty ? .empty : .data(cards)
        shouldShowSettingsButton = !cards.isEmpty
    }

    private func filteredCards() -> [DashboardCard] {
        var filteredCards = cards.all.filter { $0.shouldShow && !courseSectionStatus.isAllSectionsExpired(for: $0, in: courses.all) }

        if showOnlyTeacherEnrollment {
            filteredCards = filteredCards.filter { $0.isTeacherEnrollment }
        }

        return filteredCards
    }
}

extension DashboardCardsViewModel: WCSessionDelegate {

    func sendMessageToWatch(_ message: [String: Any]) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }

    func send(courses: [Course]) {
        sendMessageToWatch(["courses": courses.map { convert($0) }])
    }

    func convert(_ course: Course) -> WatchCourse {
        WatchCourse(id: ID(course.id), name: course.name ?? "", code: course.termName ?? "", grade: course.displayGrade, colorHex: course.courseColor, imageURL: course.imageDownloadURL)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS WCSession active")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS WCSession inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS WCSession deactivated")
    }
}

struct WatchCourse: Codable, Identifiable {
    var id: ID
    let name: String
    let code: String
    let grade: String?
    let colorHex: String?
    let imageURL: URL?
}
