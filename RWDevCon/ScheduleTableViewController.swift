import Foundation
import UIKit

class ScheduleTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!
  var startDate: NSDate?

  var selectedSession: Session?
  var selectedIndexPath: NSIndexPath?
  var selectedSectionCount = 0

  var isActive = false
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundColor = UIColor(patternImage: UIImage(named: "pattern")!)

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
    logoImageView.contentMode = UIViewContentMode.Bottom
    logoImageView.frame.size.height += 40
    tableView.tableHeaderView = logoImageView

    NSNotificationCenter.defaultCenter().addObserverForName(MyScheduleSomethingChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      if self.isActive {
        self.refreshSelectively()
      }
    }
  }

  func refreshSelectively() {
    if dataSource.favoritesOnly {
      if let selectedIndexPath = selectedIndexPath {
        if selectedSession != nil && !selectedSession!.isFavorite {
          // selected session is no longer a favorite!
          tableView.deleteRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .Automatic)

          self.selectedSession = nil
          self.selectedIndexPath = nil
          
          if splitViewController!.collapsed {
            navigationController?.popViewControllerAnimated(true)
          } else {
            performSegueWithIdentifier("tableShowDetail", sender: self)
          }
        } else {
          tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
      }

      return
    }

    if let selectedIndexPath = selectedIndexPath {
      tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .None)
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if let visibleRows = tableView.indexPathsForVisibleRows() {
      tableView.reloadRowsAtIndexPaths(visibleRows, withRowAnimation: .None)
    }
  }

  override func willMoveToParentViewController(parent: UIViewController?) {
    super.willMoveToParentViewController(parent)

    tableView.contentInset.bottom = bottomHeight
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let destNav = segue.destinationViewController as? UINavigationController {
      if let dest = destNav.topViewController as? SessionViewController {
        dest.coreDataStack = coreDataStack

        selectedIndexPath = tableView.indexPathForSelectedRow()
        if selectedIndexPath != nil {
          selectedSession = dataSource.sessionForIndexPath(selectedIndexPath!)
        } else {
          selectedSession = nil
        }
        dest.session = selectedSession
      }
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 48
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: 48))
    header.backgroundColor = UIColor(red: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 0.4)

    let label = UILabel()
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.text = dataSource.distinctTimes[section].uppercaseString
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "AvenirNext-Medium", size: 18)
    header.addSubview(label)

    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[label]-|", options: nil, metrics: nil, views: ["label": label]) +
      [NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: header, attribute: .CenterY, multiplier: 1.0, constant: 4)])


    return header
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

}
