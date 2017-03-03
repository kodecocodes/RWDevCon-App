import Foundation
import UIKit

let MyScheduleSomethingChangedNotification = "com.razeware.rwdevcon.notifications.myScheduleChanged"

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

    title = session?.title

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 76

    navigationController?.navigationBar.barStyle = UIBarStyle.default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), for: UIBarMetrics.default)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    if session == nil {
      return 0
    } else {
      return 3
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == Sections.info {
      return 4
    } else if section == Sections.description {
      return 1
    } else if section == Sections.presenters {
      return session.presenters.count
    }

    return 0
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == Sections.info && indexPath.row == 3){
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath) as! DetailTableViewCell

      cell.keyLabel.text = "My Schedule".uppercased()
      if session.isFavorite {
        cell.valueButton.setTitle("Remove from My Schedule", for: UIControlState())
      } else {
        cell.valueButton.setTitle("Add to My Schedule", for: UIControlState())
      }
      cell.valueButton.addTarget(self, action: #selector(SessionViewController.myScheduleButton(_:)), for: .touchUpInside)

      return cell
    } else if indexPath.section == Sections.info && indexPath.row == 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath) as! DetailTableViewCell

      cell.keyLabel.text = "Where".uppercased()
      cell.valueButton.setTitle(session.room.name, for: UIControlState())
      if session.isParty {
        cell.valueButton.setTitleColor(view.tintColor, for: UIControlState())
        cell.valueButton.addTarget(self, action: #selector(SessionViewController.roomDetails(_:)), for: .touchUpInside)
      } else {
        cell.valueButton.setTitleColor(UIColor.darkText, for: UIControlState())
      }
      return cell
    } else if indexPath.section == Sections.info {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailTableViewCell

      if indexPath.row == 0 {
        cell.keyLabel.text = "Track".uppercased()
        cell.valueLabel.text = session.track.name
      } else if indexPath.row == 1 {
        cell.keyLabel.text = "When".uppercased()
        cell.valueLabel.text = session.startDateTimeString
      }

      return cell
    } else if indexPath.section == Sections.description {
      let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections.presenters {
      let cell = tableView.dequeueReusableCell(withIdentifier: "presenter", for: indexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person

      if let image = UIImage(named: presenter.identifier) {
        cell.squareImageView.image = image
      } else {
        cell.squareImageView.image = UIImage(named: "RW_logo")
      }
      cell.nameLabel.text = presenter.fullName
      cell.bioLabel.text = presenter.bio
      if presenter.twitter != "" {
        cell.twitterButton.isHidden = false
        cell.twitterButton.setTitle("@\(presenter.twitter)", for: UIControlState())
        cell.twitterButton.addTarget(self, action: #selector(SessionViewController.twitterButton(_:)), for: .touchUpInside)
      } else {
        cell.twitterButton.isHidden = true
      }

      return cell
    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as UITableViewCell
      return cell
    }
  }

  func roomDetails(_ sender: UIButton) {
    if let roomVC = storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as? RoomViewController {
      roomVC.room = session.room
      roomVC.title = session.room.name
      navigationController?.pushViewController(roomVC, animated: true)
    }
  }

  func myScheduleButton(_ sender: UIButton) {
    session.isFavorite = !session.isFavorite

    tableView.reloadSections(IndexSet(integer: Sections.info), with: .automatic)
    NotificationCenter.default.post(name: Notification.Name(rawValue: MyScheduleSomethingChangedNotification), object: self, userInfo: ["session": session])
  }

  func twitterButton(_ sender: UIButton) {
    UIApplication.shared.openURL(URL(string: "http://twitter.com/\(sender.title(for: UIControlState())!)")!)
  }
}
