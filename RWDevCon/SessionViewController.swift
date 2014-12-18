
import UIKit

class SessionViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var session: Session!

  struct Sections {
    static let info = 0
    static let description = 1
    static let presenters = 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    assert(session != nil, "Session view controller needs a session!")

    title = session.title

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 76
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == Sections.info {
      return 4
    } else if section == Sections.description {
      return 1
    } else if section == Sections.presenters {
      return session.presenters.count
    }

    return 0
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == Sections.info {
      if session.sessionNumber == "" {
        return "Summary"
      } else {
        return "Session #\(session.sessionNumber)"
      }
    } else if section == Sections.description {
      return "Description"
    } else if section == Sections.presenters {
      if session.presenters.count == 1 {
        return "Presenter"
      } else if session.presenters.count > 1 {
        return "Presenters"
      }
    }
    return nil
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == Sections.info && indexPath.row == 3 {
      let cell = tableView.dequeueReusableCellWithIdentifier("detailButton", forIndexPath: indexPath) as DetailTableViewCell

      cell.keyLabel.text = "My Schedule"
      if session.isFavorite {
        cell.valueButton.setTitle("Remove from My Schedule", forState: .Normal)
      } else {
        cell.valueButton.setTitle("Add to My Schedule", forState: .Normal)
      }
      cell.valueButton.addTarget(self, action: "myScheduleButton:", forControlEvents: .TouchUpInside)

      return cell
    } else if indexPath.section == Sections.info {
      let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as DetailTableViewCell

      if indexPath.row == 0 {
        cell.keyLabel.text = "Track"
        cell.valueLabel.text = session.track.name
      } else if indexPath.row == 1 {
        cell.keyLabel.text = "Where"
        cell.valueLabel.text = session.room.name
      } else if indexPath.row == 2 {
        cell.keyLabel.text = "When"
        cell.valueLabel.text = session.startDateTimeString
      }

      return cell
    } else if indexPath.section == Sections.description {
      let cell = tableView.dequeueReusableCellWithIdentifier("label", forIndexPath: indexPath) as LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections.presenters {
      let cell = tableView.dequeueReusableCellWithIdentifier("presenter", forIndexPath: indexPath) as PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as Person

      if let image = UIImage(named: presenter.identifier) {
        cell.squareImageView.image = image
      } else {
        cell.squareImageView.image = UIImage(named: "RW_logo")
      }
      cell.nameLabel.text = presenter.fullName
      cell.bioLabel.text = presenter.bio
      if presenter.twitter != "" {
        cell.twitterButton.hidden = false
        cell.twitterButton.setTitle("@\(presenter.twitter)", forState: .Normal)
        cell.twitterButton.addTarget(self, action: "twitterButton:", forControlEvents: .TouchUpInside)
      } else {
        cell.twitterButton.hidden = true
      }

      return cell
    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
      return cell
    }
  }

  func myScheduleButton(sender: UIButton) {
    session.isFavorite = !session.isFavorite

    tableView.reloadSections(NSIndexSet(index: Sections.info), withRowAnimation: .Automatic)
  }

  func twitterButton(sender: UIButton) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/\(sender.titleForState(.Normal)!)")!)
  }

}
