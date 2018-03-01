/// Copyright (c) 2018 Razeware LLC
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
import UserNotifications

private let kSessionNotificationNotice = TimeInterval(5 * 60)

protocol SessionFavoriter {
  func toggleFavorite(session: Session)
}

extension SessionFavoriter where Self: UIViewController {
  func toggleFavorite(session: Session) {
    session.toggleFavorite()

    if session.isFavorite {
      scheduleNotificationIfNeeded(for: session)
    } else {
      cancelNotification(for: session)
    }
  }

  private func scheduleNotificationIfNeeded(for session: Session) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        switch settings.authorizationStatus {
        case .notDetermined:
          self.promptForNotification(for: session)

        case .authorized:
          self.scheduleLocalNotification(for: session)

        case .denied:
          break
        }
      }
    }
  }

  private func promptForNotification(for session: Session) {
    let title = NSLocalizedString("FAVORITE_NOTIFICATION_ALERT_TITLE", comment: "")
    let message = NSLocalizedString("FAVORITE_NOTIFICATION_ALERT_MESSAGE", comment: "")
    let cancel = NSLocalizedString("FAVORITE_NOTIFICATION_ALERT_CANCEL", comment: "")
    let OK = NSLocalizedString("FAVORITE_NOTIFICATION_ALERT_OK", comment: "")

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: OK, style: .default) { _ in
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { success, error in
        if !success {
          return
        }

        DispatchQueue.main.async {
          self.scheduleLocalNotification(for: session)
        }
      }
    })

    present(alert, animated: true, completion: nil)
  }

  private func scheduleLocalNotification(for session: Session) {
    let content = UNMutableNotificationContent()
    content.title = NSLocalizedString("NOTIFICATION_TITLE", comment: "")
    content.body = String(format: NSLocalizedString("NOTIFICATION_SUBTITLE_FORMAT", comment: ""),
                          session.title, session.location)

    let timeInterval = session.date.start.timeIntervalSinceNow - kSessionNotificationNotice
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: session.id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  private func cancelNotification(for session: Session) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [session.id])
  }
}
