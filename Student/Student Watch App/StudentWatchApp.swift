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

import SwiftUI
import WatchKit
import WatchConnectivity

@main
struct StudentWatchApp: App {

    let viewModel = ViewModel(courses: [
        WatchCourse(name: "Introduction to Psychology",
                    code: "PSYC-101",
                    grade: "10%",
                    colorHex: "#FF8C00",
                    imageURL: "https://example.com/psychology.png",
                    discussions: 5, assignments: 0, messages: 5),
        WatchCourse(name: "Calculus I", code: "MATH-121", grade: "30%", colorHex: "#FFD700", imageURL: "https://example.com/calculus.png", discussions: 4, assignments: 2, messages: 1),
        WatchCourse(name: "American History", code: "HIST-201", grade: "40%", colorHex: "#1E90FF", imageURL: "https://example.com/history.png", discussions: 16, assignments: 4, messages: 3),
        WatchCourse(name: "Computer Science I", code: "CSCI-101", grade: "B+", colorHex: "#FF69B4", imageURL: "https://example.com/computer-science.png", discussions: 20, assignments: 2, messages: 8),
        WatchCourse(name: "Environmental Science",
                    code: "ENVS-101",
                    grade: "A-",
                    colorHex: "#00FF7F",
                    imageURL: "https://example.com/environmental-science.png",
                    discussions: 3, assignments: 1, messages: 9),
        WatchCourse(name: "Introduction to Sociology", code: "SOC-101", grade: "100%", colorHex: "#00BFFF", imageURL: "https://example.com/sociology.png", discussions: 9, assignments: 3, messages: 7),
        WatchCourse(name: "Creative Writing", code: "ENGL-210", grade: "F-", colorHex: "#FF69B4", imageURL: "https://example.com/creative-writing.png", discussions: 1, assignments: 1, messages: 2),
        WatchCourse(name: "Marketing Principles", code: "MKTG-301", grade: "C", colorHex: "#A9A9A9", imageURL: "https://example.com/marketing.png", discussions: 0, assignments: 1, messages: 13),
        WatchCourse(name: "Physics I", code: "PHYS-101", grade: "0%", colorHex: "#1E90FF", imageURL: "https://example.com/physics.png", discussions: 7, assignments: 2, messages: 4),
        WatchCourse(name: "Introduction to Ethics", code: "PHIL-101", grade: "D", colorHex: "#00FF7F", imageURL: "https://example.com/ethics.png", discussions: 8, assignments: 3, messages: 1),
    ])

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
