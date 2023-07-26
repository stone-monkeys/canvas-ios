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

import SwiftUI

public class BookmarksViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[BookmarkCellViewModel]> = .loading

    public lazy private (set) var bookmarks = AppEnvironment.shared.subscribe(GetBookmarks()) { [weak self] in
        self?.bookmarksDidUpdate()
    }

    public init() {}

    public func viewDidAppear() {
        state = .loading
        bookmarks.exhaust()
    }

    private func bookmarksDidUpdate() {
        let bookmarkCells = bookmarks.all.map {
            BookmarkCellViewModel(id: $0.id, name: $0.name, url: $0.url)
        }
        if bookmarkCells.isEmpty {
            state = .empty
        } else {
            state = .data(bookmarkCells)
        }
    }

#if DEBUG

    init(state: ViewModelState<[BookmarkCellViewModel]>) {
        self.state = state
    }

#endif
}
