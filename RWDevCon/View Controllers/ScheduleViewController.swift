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

private let kSessionCell = "SessionCell"
private let kSectionHeader = "ScheduleSectionHeaderView"

final class ScheduleViewController: UIViewController, SessionFavoriter {
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var sessionFilterControl: UISegmentedControl!

  private let dimView = UIView()

  private lazy var conference = ConferenceManager.current!
  private var displayedSessions: [[Session]] {
    return sessionFilterControl.selectedSegmentIndex == 0 ? conference.sessions : conference.favoriteSessions
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    updateForConference(conference)
    registerForPreviewing(with: self, sourceView: view)
    updateFilterOptions()
    setUpTableView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: false)
    }

    let image = UIImage(named: "rwdevcon-bg")
    navigationController?.navigationBar.setBackgroundImage(image, for: .default)
    navigationController?.setToolbarHidden(false, animated: true)

    // Favorites could have changed on a detail screen so reload filter options
    updateFilterOptions()
  }

  private func updateForConference(_ conference: Conference) {
    self.conference = conference
    titleLabel.text = "▼  " + conference.name
    tableView.reloadData()
  }

  private func updateFilterOptions() {
    let favoriteSessions = conference.sessions.flatMap { $0 }.filter { $0.isFavorite }
    sessionFilterControl.setEnabled(!favoriteSessions.isEmpty, forSegmentAt: 1)

    if favoriteSessions.isEmpty {
      sessionFilterControl.selectedSegmentIndex = 0
      sessionFilterControl.sendActions(for: .valueChanged)
    }
  }

  private func setUpTableView() {
    let cellNib = UINib(nibName: kSessionCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: kSessionCell)

    let headerNib = UINib(nibName: kSectionHeader, bundle: nil)
    tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: kSectionHeader)
  }

  @IBAction private func showCurrentSessions() {
    guard let currentSession = displayedSessions.flatMap({ $0 })
                                 .first(where: { $0.date.contains(Date()) || $0.date.start > Date() }) else
    {
      return
    }

    for (section, group) in displayedSessions.enumerated() {
      if let row = group.index(of: currentSession) {
        let indexPath = IndexPath(row: row, section: section)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
      }
    }
  }

  @IBAction private func toggleFavoritesFilter() {
    tableView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? ConferenceSelectionTableViewController,
      let tap = sender as? UITapGestureRecognizer
    {
      destination.popoverPresentationController?.sourceRect = tap.view?.bounds ?? .zero
      destination.popoverPresentationController?.delegate = self
      destination.conferences = ConferenceManager.allConferences
      destination.selectedConference = conference
      destination.completion = { [weak self] in self?.updateForConference($0) }
    }
  }
}

extension ScheduleViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }

  func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
    let topView = splitViewController?.view ?? view!

    dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    dimView.frame = topView.bounds
    topView.addSubview(dimView)
  }

  func popoverPresentationControllerDidDismissPopover(
    _ popoverPresentationController: UIPopoverPresentationController)
  {
    dimView.removeFromSuperview()
  }
}

extension ScheduleViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return displayedSessions.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedSessions[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kSessionCell) as? SessionCell
    cell?.session = displayedSessions[indexPath.section][indexPath.row]
    return cell ?? UITableViewCell()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let dequeuedView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kSectionHeader)
    let headerView = dequeuedView as? ScheduleSectionHeaderView
    headerView?.titleLabel.text = displayedSessions[section].first?.dayAndTime
    return headerView
  }
}

extension ScheduleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sessionViewController: SessionViewController = storyboard!.instantiateViewController()
    sessionViewController.session = displayedSessions[indexPath.section][indexPath.row]

    if self.splitViewController?.isCollapsed == true {
      showDetailViewController(sessionViewController, sender: nil)
    } else {
      let navigationController = self.splitViewController?.viewControllers.last as? UINavigationController
      navigationController?.setViewControllers([sessionViewController], animated: false)
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return displayedSessions[section].first?.dayAndTime
  }

  @available(iOS 11, *)
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration?
  {
    let session = displayedSessions[indexPath.section][indexPath.row]
    let title = NSLocalizedString(session.isFavorite ? "UNMARK_AS_FAVORITE" : "MARK_AS_FAVORITE", comment: "")

    return UISwipeActionsConfiguration(actions: [
      UIContextualAction(style: .normal, title: title) { _, _, completion in
        self.updateTableView(afterUnfavoritingSession: session, at: indexPath)

        completion(true)
    }])
  }

  private func updateTableView(afterUnfavoritingSession session: Session, at indexPath: IndexPath) {
    if sessionFilterControl.selectedSegmentIndex == 0 {
      toggleFavorite(session: session)
      return updateFilterOptions()
    }

    tableView.beginUpdates()
    if displayedSessions[indexPath.section].count == 1 {
      tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
    } else {
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    toggleFavorite(session: session)
    tableView.endUpdates()

    updateFilterOptions()
  }
}

extension ScheduleViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         viewControllerForLocation location: CGPoint) -> UIViewController?
  {
    let convertedPoint = view.convert(location, to: tableView)
    guard let indexPath = tableView.indexPathForRow(at: convertedPoint) else {
      return nil
    }

    if let sourceRect = tableView.cellForRow(at: indexPath)?.frame {
      previewingContext.sourceRect = sourceRect
    }

    let sessionViewController: SessionViewController? = storyboard?.instantiateViewController()
    sessionViewController?.session = displayedSessions[indexPath.section][indexPath.row]

    return sessionViewController
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController)
  {
    showDetailViewController(viewControllerToCommit, sender: nil)
  }
}
