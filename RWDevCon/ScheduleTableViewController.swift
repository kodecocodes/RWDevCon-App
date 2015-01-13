
import UIKit

class ScheduleTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!
  var startDate: NSDate?

  var selectedSession: Session?
  var selectedIndexPath: NSIndexPath?
  var selectedSectionCount = 0

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundColor = UIColor.clearColor()
    dataSource = tableView.dataSource! as ScheduleDataSource
    dataSource.coreDataStack = coreDataStack
    dataSource.startDate = startDate
    if startDate == nil {
      dataSource.endDate = nil
      dataSource.favoritesOnly = true
    } else {
      dataSource.endDate = NSDate(timeInterval: 60*60*24, sinceDate: startDate!)
      dataSource.favoritesOnly = false
    }

    dataSource.tableCellConfigurationBlock = { (cell: ScheduleTableViewCell, indexPath: NSIndexPath, session: Session) -> () in
      let track = session.track.name
      let room = session.room.name
      let sessionNumber = session.sessionNumber

      cell.nameLabel.text = (!self.dataSource.favoritesOnly && session.isFavorite ? "★ " : "") + session.title

      if self.dataSource.favoritesOnly {
        cell.timeLabel.text = "\(session.startTimeString) • \(track) • \(room)"
      } else if sessionNumber != "" {
        cell.timeLabel.text = "\(sessionNumber) • \(track) • \(room)"
      } else {
        cell.timeLabel.text = "\(track) • \(room)"
      }
    }

    let logoImageView = UIImageView(image: UIImage(named: "logo-rwdevcon"))
    logoImageView.contentMode = UIViewContentMode.Center
    logoImageView.frame.size.height += 40
    tableView.tableHeaderView = logoImageView
  }

  override func willMoveToParentViewController(parent: UIViewController?) {
    super.willMoveToParentViewController(parent)

    tableView.contentInset.bottom = bottomHeight
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let dest = segue.destinationViewController as? SessionViewController {
      dest.coreDataStack = coreDataStack

      if let parent = parentViewController as? ScheduleViewController {
        selectedIndexPath = tableView.indexPathForSelectedRow()
        selectedSession = dataSource.sessionForIndexPath(selectedIndexPath!)
        dest.session = selectedSession
      }
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62
  }

}
