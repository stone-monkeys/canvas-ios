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

import Foundation
import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if !viewModel.courses.isEmpty {
                        ForEach(viewModel.courses, id: \.id) { course in
                            CourseRowView(course: course)
                        }
                    }
                }
            }
        }
    }
}

struct CourseRowView: View {
    let course: WatchCourse

    var body: some View {
        NavigationLink(destination: CourseDetailsView(course: course)) {
            ZStack {
                // courseImage
                courseInfo
            }
        }
        .clipped()
        .frame(height: 70)
        .tint((course.color ?? .clear).opacity(2))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke((course.color ?? .clear), lineWidth: 1).opacity(0.5))
    }

    private var courseImage: some View {
        if let imageURL = course.imageURL {
            return AnyView(
                AsyncImage(url: URL(string: imageURL))
                    .scaledToFit()
                    .blur(radius: 5)
            )
        } else {
            return AnyView(
                Color.clear
            )
        }
    }

    private var courseInfo: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                courseName
                Text(course.code)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            Spacer()
            PercentPillView(text: course.grade, color: course.color ?? .white)
        }.padding(.vertical)
    }

    private var courseName: some View {
        HStack {
            Text(course.name)
                .font(.headline)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .foregroundColor(course.color ?? .white)
                .brightness(0.3)
            Spacer()
        }
    }
}

struct CourseDetailsView: View {
    let course: WatchCourse

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(course.name).padding().font(.title3)
                Spacer()
            }.background(RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(course.color ?? .clear))
            List {
                HStack {
                    Text("Grade:")
                    Spacer()
                    Text(course.grade ?? "--")
                }.font(.title3)
                HStack {
                    Text("Assignments:")
                    Spacer()
                    Text("\(course.assignments)")
                }.font(.title3)
                HStack {
                    Text("Discussions:")
                    Spacer()
                    Text("\(course.discussions)")
                }.font(.title3)
                HStack {
                    Text("Messages:")
                    Spacer()
                    Text("\(course.messages)")
                }.font(.title3)
            }.listStyle(.plain)
        }
    }
}

class ViewModel: NSObject, WCSessionDelegate, ObservableObject {

    @Published var courses = [WatchCourse]()
    private let session: WCSession = .default

    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }

    init(courses: [WatchCourse]) {
        super.init()
        session.delegate = self
        session.activate()
        self.courses = courses
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState.rawValue)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let data = message["courses"] as? Data {
            do {
                let decodedObject = try JSONDecoder().decode([WatchCourse].self, from: data)
                DispatchQueue.main.async {
                    self.courses = decodedObject
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }
    }
}

struct PercentPillView: View {
    let text: String?
    let color: Color?

    var body: some View {
        if let text = text {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color ?? .white)
                .brightness(0.4)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.red, lineWidth: 0)
                )
        }
    }
}

struct WatchCourse: Codable, Identifiable {
    var id = UUID()
    let name: String
    let code: String
    let grade: String?
    let colorHex: String?
    let imageURL: String?
    let discussions: Int
    let assignments: Int
    let messages: Int

    var color: Color? {
        guard let colorHex = colorHex else { return nil }
        return Color(colorHex)
    }
}

struct WatchCourseDetail: Identifiable {
    var id = UUID()
    let courseDetailName: String
    let courseDetailImage: Image
}

struct ContentView_Previews: PreviewProvider {

    static let viewModel = ViewModel(courses: [
        WatchCourse(name: "Introduction to Psychology",
                    code: "PSYC-101",
                    grade: "10%",
                    colorHex: "#FF8C00",
                    imageURL: "https://example.com/psychology.png",
                    discussions: 5, assignments: 0, messages: 5),
    ]
)

    static var previews: some View {
        ContentView(viewModel: viewModel)
        CourseDetailsView(course: viewModel.courses.first!)
    }
}

extension Color {
    init(_ hex: String) {
        // Remove the '#' character if it exists
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        // Parse the hex string into red, green, and blue components
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
