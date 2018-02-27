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

import UIKit
import NotificationCenter

private let kWidgetIdentifier = "com.razeware.RWDevCon.Today"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
  {
    ConferenceManager.downloadLatestConferences()
    ConferenceManager.loadStoredData()

    guard let splitViewController = window?.rootViewController as? UISplitViewController else {
      return true
    }

    let conference = ConferenceManager.current
    let initialSession = conference?.currentSessions.first ?? conference?.sessions.flatMap { $0 }.first
    ViewControllerRouter.shared.configureSplitViewController(splitViewController,
                                                             initialSession: initialSession!)

    let widgetHasContent = !conference!.currentSessions.isEmpty || !conference!.upcomingSessions.isEmpty
    NCWidgetController.widgetController().setHasContent(widgetHasContent,
                                                        forWidgetWithBundleIdentifier: kWidgetIdentifier)

    return true
  }

  func application(_ app: UIApplication, open url: URL,
                   options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
  {
    ConferenceManager.downloadLatestConferences()
    ConferenceManager.loadStoredData()

    guard let splitViewController = window?.rootViewController as? UISplitViewController else {
      return false
    }

    let conference = ConferenceManager.current
    let initialSession = conference?.currentSessions.first ?? conference?.sessions.flatMap { $0 }.first

    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let sessionQueryItem = components.queryItems?.first(where: { $0.name == "session_id" }),
      let sessionID = sessionQueryItem.value
    {
      // Parsed deep link with specific session
      let session = ConferenceManager.current.session(forID: sessionID) ?? initialSession
      ViewControllerRouter.shared.configureSplitViewController(splitViewController, initialSession: session!)
    } else {
      ViewControllerRouter.shared.configureSplitViewController(splitViewController,
                                                               initialSession: initialSession!)
    }

    return true
  }
}
