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

private let kSessionCell = "SessionCell"
private let kWidgetIdentifier = "com.razeware.RWDevCon.Today"

final class TodayViewController: UIViewController {
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var countdownContainer: UIView!
  @IBOutlet private var countdownTitle: UILabel!
  @IBOutlet private var countdownSubtitle: UILabel!

  var displayedSessions: [Session] = [] {
    didSet { updateUI() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    ConferenceManager.loadStoredData()

    let currentSessions = ConferenceManager.current.currentSessions
    let upcomingSessions = ConferenceManager.current.upcomingSessions
    displayedSessions = currentSessions.count > 2 ? currentSessions : currentSessions + upcomingSessions
    countdownTitle.text = ConferenceManager.current.timeUntilStart

    let nib = UINib(nibName: "SessionCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: kSessionCell)
  }

  private func updateUI() {
    NCWidgetController.widgetController().setHasContent(!displayedSessions.isEmpty,
                                                        forWidgetWithBundleIdentifier: kWidgetIdentifier)

    countdownContainer.isHidden = !displayedSessions.isEmpty
    tableView.isHidden = displayedSessions.isEmpty

    if !displayedSessions.isEmpty {
      extensionContext?.widgetLargestAvailableDisplayMode = .expanded
      tableView.reloadData()
    }
  }

  @IBAction private func launchApp() {
    extensionContext?.open(URL(string: "rwdevcon://")!, completionHandler: nil)
  }
}

extension TodayViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedSessions.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kSessionCell) as? SessionCell
    cell?.session = displayedSessions[indexPath.row]
    cell?.update(forDisplayMode: .compact)
    return cell ?? UITableViewCell()
  }
}

extension TodayViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sessionID = displayedSessions[indexPath.row].id
    let urlString = "rwdevcon://?session_id=" + sessionID
    if let url = URL(string: urlString) {
      extensionContext?.open(url, completionHandler: nil)
    }
  }
}

extension TodayViewController: NCWidgetProviding {
  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    ConferenceManager.downloadLatestConferences { success in
      completionHandler(success ? .newData : .failed)
    }
  }

  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode,
                                        withMaximumSize maxSize: CGSize)
  {
    let height = min(displayedSessions.count, 3) * SessionCellDisplayMode.compact.rawValue
    preferredContentSize = CGSize(width: maxSize.width, height: min(CGFloat(height), maxSize.height))
  }
}
