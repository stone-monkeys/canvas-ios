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

import Core
import SwiftUI

struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel
    @Environment(\.viewController) private var viewController

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        BaseHorizonScreen {
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(refreshable: true)
            ) { proxy in
                VStack(spacing: 0) {
                    LargeTitleView(title: viewModel.title)
                    ForEach(viewModel.programs) { program in
                        if program.currentModuleItem != nil, !program.upcomingModuleItems.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                SectionTitleView(title: program.name)
                                CertificateProgressBar(
                                    maxWidth: proxy.size.width,
                                    progress: program.progress,
                                    progressString: program.progressString
                                )
                                currentModuleView(moduleItem: program.currentModuleItem)
                                whatsNextModuleView(
                                    proxy: proxy,
                                    programName: program.name,
                                    moduleItems: program.upcomingModuleItems
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.backgroundLightest)
            .navigationBarItems(trailing: logoutButton)
            .scrollIndicators(.hidden, axes: .vertical)
        }
    }

    private var logoutButton: some View {
        Button {
            SessionInteractor().logout()
        } label: {
            Image.logout.tint(Color.textLightest)
        }
    }

    @ViewBuilder
    private func currentModuleView(moduleItem: HModuleItem?) -> some View {
        if let currentModuleItem = moduleItem {
            ZStack {
                VStack {
                    Rectangle()
                        .fill(Color.backgroundLightest)
                        .frame(height: 200)
                        .padding(16)
                    HStack {
                        VStack(alignment: .leading) {
                            BodyTextView(title: currentModuleItem.title)
                            Text("20 MINS")
                                .font(.regular12)
                                .foregroundStyle(Color.textDark)
                        }
                        Spacer()
                        Button {
                            print(currentModuleItem)
                            if let url = currentModuleItem.url {
                                AppEnvironment.shared.router.route(to: url, from: viewController)
                            }

                        } label: {
                            Text("Start")
                                .font(.regular16)
                                .padding(.all, 8)
                                .background(Color.backgroundDarkest)
                                .foregroundColor(Color.textLightest)
                                .cornerRadius(3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color.backgroundLight)
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func whatsNextModuleView(
        proxy: GeometryProxy,
        programName: String,
        moduleItems: [HModuleItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitleView(title: "What's next")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(moduleItems) { moduleItem in
                        ProgramItemView(
                            screenWidth: proxy.size.width,
                            title: moduleItem.title,
                            icon: Image(systemName: "doc"),
                            duration: "60 mins",
                            certificate: programName
                        )
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

#Preview {
    DashboardView(viewModel: .init(interactor: GetProgramsInteractor()))
}
