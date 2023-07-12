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

import Combine
import CombineExt

protocol CourseSyncPeopleInteractor: CourseSyncContentInteractor {}

class CourseSyncPeopleInteractorLive: CourseSyncPeopleInteractor {

    var associatedTabType: TabName { .people }

    func getContent(courseId: String) -> AnyPublisher<Void, Error> {

        let context: Context = .course(courseId)

        return [
            Self.fetchCourseColors(),
            Self.fetchCourse(context: context),
            Self.fetchGroup(context: context),
            Self.fetchUsers(context: context)
                .flatMap { users in
                    Self.fetchCurrentGradingPeriodId(courseId: courseId)
                        .flatMap {
                            Self.fetchUserData(context: context, users: users, currentGradingPeriodID: $0)
                    }
                }.eraseToAnyPublisher(),
        ]
            .zip()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchUserData(context: Context, users: [User], currentGradingPeriodID: String?) -> AnyPublisher<Void, Error> {
        Just(users)
            .map { $0.map { user in user.id} }
            .flatMap { userIDs in
                Publishers.Sequence(sequence: userIDs)
                    .setFailureType(to: Error.self)
                    .flatMap {
                        Publishers.Zip3(Self.fetchSingleUser(context: context, userID: $0),
                                        Self.fetchSubmissionsForStudent(context: context, userID: $0),
                                        Self.fetchEnrollments(context: context, currentGradingPeriodID: currentGradingPeriodID, userID: $0) )
                    }.collect().mapToVoid()
            }.eraseToAnyPublisher()
    }

    private static func fetchCourseColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchCourse(context: Context) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCourse(courseID: context.id))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchSubmissionsForStudent(context: Context, userID: String) -> AnyPublisher<Void, Error> {
            ReactiveStore(useCase: GetSubmissionsForStudent(context: context, studentID: userID))
                .getEntities()
                .mapToVoid()
                .eraseToAnyPublisher()
        }

    private static func fetchSingleUser(context: Context, userID: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCourseSingleUser(context: context, userID: userID))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchUsers(context: Context) -> AnyPublisher<[User], Error> {
        ReactiveStore(useCase: GetContextUsers(context: context))
            .getEntities()
            .eraseToAnyPublisher()
    }

    private static func fetchGroup(context: Context) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetGroup(groupID: context.id))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchCurrentGradingPeriodId(courseId: String) -> AnyPublisher<String?, Error> {
        ReactiveStore(useCase: GetGradingPeriods(courseID: courseId))
            .getEntities()
            .map { $0.current?.id }
            .eraseToAnyPublisher()
    }

    private static func fetchEnrollments(context: Context, currentGradingPeriodID: String?, userID: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            let request = GetEnrollmentsRequest(context: context, gradingPeriodID: currentGradingPeriodID, states: [ .active ])
            AppEnvironment.shared.api.exhaust(request) { (enrollments, _, _) in performUIUpdate {

                let apiEnrollment = enrollments?.first {
                    $0.id != nil &&
                    $0.enrollment_state == .active &&
                    $0.user_id.value == userID
                }
                if let apiEnrollment = apiEnrollment, let id = apiEnrollment.id?.value {
                    let databaseContext = AppEnvironment.shared.database.viewContext
                    let enrollment: Enrollment = databaseContext.first(where: #keyPath(Enrollment.id), equals: id) ?? databaseContext.insert()
                    enrollment.update(fromApiModel: apiEnrollment, course: nil, in: databaseContext)
                }
                promise(.success(()))
            }}
        }.eraseToAnyPublisher()
    }
}
