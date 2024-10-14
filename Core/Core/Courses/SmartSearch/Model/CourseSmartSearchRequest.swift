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

struct CourseSmartSearchRequest: APIRequestable {
    typealias Response = APICourseSmartSearch

    let courseId: String
    let searchText: String
    let filter: [String]?

    var path: String {
        "/api/v1/courses/\(courseId)/smartsearch"
    }

    var query: [APIQueryItem] {
        return [
            .value("q", searchText),
            filter.flatMap { .array("filter", $0) }
        ]
        .compactMap({ $0 })
    }
}

struct APICourseSmartSearch: Codable {
    let results: [SearchResult]
    let status: String?
    let indexing_progress: Double?
}
