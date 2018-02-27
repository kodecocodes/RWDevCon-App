/// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct Conference: Codable {
  let id: String
  let name: String
  let date: DateInterval
  let sessions: [[Session]]

  init(from decoder: Decoder) throws {
    let codingContainer = try decoder.container(keyedBy: CodingKeys.self)

    id = try codingContainer.decode(String.self, forKey: .id)
    name = try codingContainer.decode(String.self, forKey: .name)
    date = try codingContainer.decode(DateInterval.self, forKey: .date)

    let sessions = try codingContainer.decode([Session].self, forKey: .sessions)
    let groups = Array(Dictionary(grouping: sessions, by: { $0.dayAndTime }).keys)

    var grouped: [[Session]] = []
    for group in groups {
      grouped.append(sessions.filter { $0.dayAndTime == group }.sorted { $0.date < $1.date })
    }

    self.sessions = grouped.sorted { $0.first!.date < $1.first!.date }
  }

  var currentSessions: [Session] {
    return sessions.flatMap { $0 }.filter { $0.date.contains(Date()) }
  }

  var upcomingSessions: [Session] {
    for group in sessions where group.first!.date.start > Date() {
      return group
    }

    return []
  }

  var favoriteSessions: [[Session]] {
    let favoritesGrouped = sessions.map {
      $0.filter { $0.isFavorite }
    }

    return favoritesGrouped.filter { !$0.isEmpty }
  }

  var timeUntilStart: String? {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour]
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1

    var calendar = Calendar.current
    calendar.timeZone = TimeZone(abbreviation: "EDT")!
    formatter.calendar = calendar

    return formatter.string(from: date.start.timeIntervalSince(Date()))
  }

  var formattedDate: String {
    let formatter = DateIntervalFormatter()
    formatter.dateTemplate = "MMMd"
    formatter.timeZone = TimeZone(abbreviation: "EDT")!
    return formatter.string(from: date) ?? ""
  }

  func session(forID id: String) -> Session? {
    return currentSessions.first { $0.id == id }
  }
}

extension Conference: Equatable {
  static func == (lhs: Conference, rhs: Conference) -> Bool {
    return lhs.name == rhs.name
  }
}
