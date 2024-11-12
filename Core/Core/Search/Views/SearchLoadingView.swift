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
import Lottie

struct SearchLoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                LottieView(name: "panda_searching", loopMode: .loop)
                    .frame(height: 170)
                Text("Hang Tight, We're Fetching Your Results!", bundle: .core)
                    .textStyle(.heading)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text("We’re working hard to find the best matches for your search. This won't take long! Thank you for your patience.", bundle: .core)
                    .font(.regular16, lineHeight: .normal)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SearchLoadingView()
}
