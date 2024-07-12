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

public enum PlannerAssembly {

    public enum Completion {
        case didCancel
        case didUpdate
    }

    // MARK: - Event

    public static func makeEventDetailsViewController(eventId: String, env: AppEnvironment = .shared) -> UIViewController {
        let interactor = CalendarEventDetailsInteractorLive(calendarEventId: eventId)
        let viewModel = CalendarEventDetailsViewModel(interactor: interactor, router: env.router)
        let view = CalendarEventDetailsScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

#if DEBUG

    public static func makeEventDetailsScreenPreview(env: AppEnvironment = .shared) -> some View {
        let interactor = CalendarEventDetailsInteractorPreview()
        let viewModel = CalendarEventDetailsViewModel(interactor: interactor, router: env.router)
        return CalendarEventDetailsScreen(viewModel: viewModel)
    }

#endif

    // MARK: - ToDo

    public static func makeCreateToDoViewController(
        calendarListProviderInteractor: CalendarFilterInteractor? = nil,
        completion: @escaping (Completion) -> Void
    ) -> UIViewController {
        let viewModel = EditCalendarToDoViewModel(
            toDoInteractor: CalendarToDoInteractorLive(),
            calendarListProviderInteractor: calendarListProviderInteractor ?? makeFilterInteractor(observedUserId: nil),
            completion: completion
        )
        let view = EditCalendarToDoScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

    public static func makeEditToDoViewController(
        plannable: Plannable,
        calendarListProviderInteractor: CalendarFilterInteractor? = nil,
        completion: @escaping (Completion) -> Void
    ) -> UIViewController {
        let viewModel = EditCalendarToDoViewModel(
            plannable: plannable,
            toDoInteractor: CalendarToDoInteractorLive(),
            calendarListProviderInteractor: calendarListProviderInteractor ?? makeFilterInteractor(observedUserId: nil),
            completion: completion
        )
        let view = EditCalendarToDoScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

    public static func makeToDoDetailsViewController(plannable: Plannable, env: AppEnvironment = .shared) -> UIViewController {
        let viewModel = CalendarToDoDetailsViewModel(
            plannable: plannable,
            interactor: CalendarToDoInteractorLive(),
            router: env.router
        )
        let view = CalendarToDoDetailsScreen(viewModel: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makeEditToDoScreenPreview() -> some View {
        let viewModel = EditCalendarToDoViewModel(
            toDoInteractor: CalendarToDoInteractorPreview(),
            calendarListProviderInteractor: CalendarFilterInteractorPreview(),
            completion: { _ in }
        )
        return EditCalendarToDoScreen(viewModel: viewModel)
    }

    public static func makeToDoDetailsScreenPreview(plannable: Plannable, env: AppEnvironment = .shared) -> some View {
        let viewModel = CalendarToDoDetailsViewModel(
            plannable: plannable,
            interactor: CalendarToDoInteractorPreview(),
            router: env.router
        )
        return CalendarToDoDetailsScreen(viewModel: viewModel)
    }

    public static func makeSelectCalendarScreenPreview() -> some View {
        let viewModel = SelectCalendarViewModel(
            calendarListProviderInteractor: CalendarFilterInteractorPreview(),
            calendarTypes: [.user, .course, .group],
            selectedCalendar: .init(nil)
        )
        return SelectCalendarScreen(viewModel: viewModel)
    }

#endif

    // MARK: - Calendar Filter

    public static func makeFilterViewController(
        observedUserId: String?,
        didDismissPicker: @escaping () -> Void
    ) -> UIViewController {
        let interactor = makeFilterInteractor(observedUserId: observedUserId)
        let viewModel = CalendarFilterViewModel(interactor: interactor, didDismissPicker: didDismissPicker)
        let view = CalendarFilterScreen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

    public static func makeFilterInteractor(observedUserId: String?) -> CalendarFilterInteractor {
        CalendarFilterInteractorLive(
            observedUserId: observedUserId,
            filterProvider: makeFilterProvider(observedUserId: observedUserId)
        )
    }

    public static func makeFilterProvider(
        observedUserId: String?,
        app: AppEnvironment.App? = AppEnvironment.shared.app
    ) -> CalendarFilterEntryProvider {
        switch app {
        case .parent:
            return CalendarFilterEntryProviderParent(observedUserId: observedUserId)
        case .student, .none:
            return CalendarFilterEntryProviderStudent()
        case .teacher:
            return CalendarFilterEntryProviderTeacher()
        }
    }

#if DEBUG

    public static func makeFilterScreenPreview() -> some View {
        let interactor = CalendarFilterInteractorPreview()
        let viewModel = CalendarFilterViewModel(interactor: interactor, didDismissPicker: {})
        return CalendarFilterScreen(viewModel: viewModel)
    }

#endif
}
