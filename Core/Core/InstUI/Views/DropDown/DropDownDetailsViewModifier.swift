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

struct DropDownDetailsViewModifier<ListContent: View>: ViewModifier {
    @Binding var state: DropDownButtonState
    @ViewBuilder let listContent: () -> ListContent

    @State private var screenFrame: CGRect = .zero
    @State private var preferredDetailsSize: CGSize?

    func body(content: Content) -> some View {
        content
            .background(content: {
                GeometryReader(content: { geometry in
                    Color.clear.screenFrame(geometry.frame(in: .global))
                })
            })
            .overlay(content: {

                if state.isDetailsShown {
                    let dims = state
                        .dimensions(given: screenFrame,
                                    prefSize: preferredDetailsSize)

                    ZStack {
                        Color
                            .clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    state.isDetailsShown = false
                                }
                        }

                        VStack {
                            Spacer()
                                .frame(width: 100, height: dims.topSpacerHeight)

                            HStack {
                                Spacer()
                                    .frame(width: dims.leftSpacerWidth, height: 100)

                                ZStack {
                                    Color.white
                                    listContent()
                                }
                                    .frame(maxWidth: dims.listMaxSize.width,
                                           maxHeight: dims.listMaxSize.height)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .shadow(radius: 4)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel(Text("Select Weekdays", bundle: .core))
                                    .accessibilityAddTraits(.isModal)
                                    .accessibilityAction(.escape) {
                                        withAnimation {
                                            state.isDetailsShown = false
                                        }
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .transition(
                        .opacity.animation(
                            .spring(duration: 0.3)
                        )
                    )
                }
            })
            .onPreferenceChange(DropDownDetailsSizePrefKey.self, perform: { size in
                preferredDetailsSize = size
            })
            .onPreferenceChange(ScreenFramePrefKey.self, perform: { value in
                screenFrame = value
            })
    }
}

extension View {

    func dropDownDetails<C: View>(
        state: Binding<DropDownButtonState>,
        @ViewBuilder content: @escaping () -> C) -> some View {
        modifier(DropDownDetailsViewModifier(state: state, listContent: content))
    }
}
