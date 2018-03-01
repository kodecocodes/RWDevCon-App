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
import UIKit

enum SessionType: String, Codable {
  case keynote
  case talk
  case workshop
  case rwconnect
  case inspiration

  var color: UIColor {
    switch self {
    case .keynote:
      return UIColor(red: 58/255, green: 46/255, blue: 57/255, alpha: 1)

    case .talk:
      return UIColor(red: 195/255, green: 172/255, blue: 206/255, alpha: 1)

    case .workshop:
      return UIColor(red: 56/255, green: 111/255, blue: 164/255, alpha: 1)

    case .rwconnect:
      return .white

    case .inspiration:
      return UIColor(red: 97/255, green: 155/255, blue: 138/255, alpha: 1)
    }
  }
}

struct Session: Codable {
  let id: String
  let title: String
  let description: String
  let type: SessionType
  let location: String
  let date: DateInterval
  let speakers: [Speaker]?
}

extension Session: Equatable {
  static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Session: Hashable {
  var hashValue: Int { return id.hashValue }
}

extension Session {
  var day: String {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("EEEE")
    formatter.timeZone = TimeZone(abbreviation: "EDT")
    return formatter.string(from: date.start)
  }

  var time: String {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("hh:mm j")
    formatter.timeZone = TimeZone(abbreviation: "EDT")
    return formatter.string(from: date.start)
  }

  var dayAndTime: String {
    let formatter = DateFormatter()
    formatter.setLocalizedDateFormatFromTemplate("EEEE hh:mm j")
    formatter.timeZone = TimeZone(abbreviation: "EDT")
    return formatter.string(from: date.start)

  }
}
