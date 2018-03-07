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

private let kFavoriteSessionsKey = "favoriteSessions"
private let kConferencesFileName = "conferences.json"
private let kSessionsURL = "https://raw.githubusercontent.com/raywenderlich/RWDevCon-App/master/RWDevCon/Supporting%20Files/conferences.json"

final class ConferenceManager {
  static var allConferences: [Conference] = []
  static var current: Conference!

  private static var storedFileURL: URL? {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    return url?.appendingPathComponent(kConferencesFileName)
  }

  fileprivate static var favoritedSessions: [Session] {
    let allFavorites = UserDefaults.standard.object(forKey: kFavoriteSessionsKey)
    let conferencesToFavorites = allFavorites as? [String: [String]] ?? [:]
    let currentConferenceFavorites = conferencesToFavorites[current.id] ?? []
    return current.sessions.flatMap { $0 }.filter { currentConferenceFavorites.contains($0.id) }
  }

  static func loadStoredData() {
    if let url = storedFileURL, let data = try? Data(contentsOf: url) {
      updateForConference(with: data)
    } else {
      let url = Bundle.main.url(forResource: "conferences", withExtension: "json")!
      let data = try! Data(contentsOf: url, options: [])
      updateForConference(with: data)
    }
  }

  static func downloadLatestConferences(completion: ((Bool) -> Void)? = nil) {
    let url = URL(string: kSessionsURL)!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let data = data {
        self.updateForConference(with: data)
        self.storeConferenceData(data)
      }

      completion?(data != nil)
    }

    task.resume()
  }

  private static func updateForConference(with data: Data) {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    allConferences = try! decoder.decode([Conference].self, from: data)
    current = allConferences.first { $0.date.start >= Date() } ?? allConferences.last
  }

  private static func storeConferenceData(_ data: Data) {
    guard let fileContents = String(data: data, encoding: .utf8), let url = storedFileURL else {
      return
    }

    let queue = DispatchQueue(label: "com.razeware.rwdevcon.filestorage")
    queue.async {
      do {
        try fileContents.write(to: url, atomically: true, encoding: .utf8)
      } catch {
        print(error)
      }
    }
  }
}

extension Session {
  var isFavorite: Bool {
    return ConferenceManager.favoritedSessions.contains(self)
  }

  func toggleFavorite(favorite: Bool? = nil) {
    let favorite = favorite ?? !isFavorite

    let allFavorites = UserDefaults.standard.object(forKey: kFavoriteSessionsKey)
    var conferencesToFavorites = allFavorites as? [String: [String]] ?? [:]
    let currentConference = ConferenceManager.current!

    if favorite {
      let newFavorites = Array(Set(ConferenceManager.favoritedSessions.map { $0.id } + [id]))
      conferencesToFavorites[currentConference.id] = newFavorites
    } else {
      conferencesToFavorites[currentConference.id] = ConferenceManager.favoritedSessions
                                                       .filter { $0.id != self.id }
                                                       .map { $0.id }
    }

    UserDefaults.standard.set(conferencesToFavorites, forKey: kFavoriteSessionsKey)
  }
}
