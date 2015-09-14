import Foundation
import AVFoundation
import AVKit
import UIKit

let MyScheduleSomethingChangedNotification = "com.razeware.rwdevcon.notifications.myScheduleChanged"

class SessionViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var session: Session!
  var sessionMode: SessionMode = .Current
  
  enum SessionMode {
    case Current
    case Archived
  }
  
  struct Sections_Current {
    static let info = 0
    static let description = 1
    static let presenters = 2
  }
  
  struct Sections_Archived {
    static let description = 0
    static let presenter = 1
    static let video = 2
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = session?.title
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 76
    
    navigationController?.navigationBar.barStyle = UIBarStyle.Default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), forBarMetrics: UIBarMetrics.Default)
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if session == nil {
      return 0
    } else {
      return 3
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if sessionMode == .Current {
      return currentSession_numberOfRowsForSection(section)
    } else if sessionMode == .Archived {
      return archivedSession_numberOfRowsForSection(section)
    }
    return 0
  }
  
  func currentSession_numberOfRowsForSection(section: Int) -> Int {
    
    if section == Sections_Current.info {
      return 4
    } else if section == Sections_Current.description {
      return 1
    } else if section == Sections_Current.presenters {
      return session.presenters.count
    }
    return 0
  }
  
  func archivedSession_numberOfRowsForSection(section: Int) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    if sessionMode == .Current {
      return currentSession_titleForHeaderInSection(section)
    } else if sessionMode == .Archived {
      return archivedSession_titleForHeaderInSection(section)
    }
    
    return nil
  }
  
  func currentSession_titleForHeaderInSection(section: Int) -> String? {
    
    if section == Sections_Current.info {
      if session.sessionNumber == "" {
        return "Summary"
      } else {
        return "Session #\(session.sessionNumber)"
      }
    } else if section == Sections_Current.description {
      return "Description"
    } else if section == Sections_Current.presenters {
      if session.presenters.count == 1 {
        return "Presenter"
      } else if session.presenters.count > 1 {
        return "Presenters"
      }
    }
    return nil
  }
  
  func archivedSession_titleForHeaderInSection(section: Int) -> String? {
    
    if section == Sections_Archived.description {
      return "Description"
    } else if section == Sections_Archived.presenter {
      return "Presenter"
    }
    return nil
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if sessionMode == .Current {
      return currentSession_cellForRowAtIndexPath(indexPath)
    } else if sessionMode == .Archived {
      return archivedSession_cellForRowAtIndexPath(indexPath)
    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
      return cell
    }
  }
  
  func currentSession_cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == Sections_Current.info && indexPath.row == 3 {
      let cell = tableView.dequeueReusableCellWithIdentifier("detailButton", forIndexPath: indexPath) as! DetailTableViewCell
      cell.keyLabel.text = "My Schedule".uppercaseString
      if session.isFavorite {
        cell.valueButton.setTitle("Remove from My Schedule", forState: .Normal)
      } else {
        cell.valueButton.setTitle("Add to My Schedule", forState: .Normal)
      }
      cell.valueButton.addTarget(self, action: "myScheduleButton:", forControlEvents: .TouchUpInside)
      return cell
    } else if indexPath.section == Sections_Current.info && indexPath.row == 2 {
      let cell = tableView.dequeueReusableCellWithIdentifier("detailButton", forIndexPath: indexPath) as! DetailTableViewCell
      
      cell.keyLabel.text = "Where".uppercaseString
      cell.valueButton.setTitle(session.room.name, forState: .Normal)
      cell.valueButton.addTarget(self, action: "roomDetails:", forControlEvents: .TouchUpInside)
      
      return cell
    } else if indexPath.section == Sections_Current.info {
      let cell = tableView.dequeueReusableCellWithIdentifier("detail", forIndexPath: indexPath) as! DetailTableViewCell
      
      if indexPath.row == 0 {
        cell.keyLabel.text = "Track".uppercaseString
        cell.valueLabel.text = session.track.name
      } else if indexPath.row == 1 {
        cell.keyLabel.text = "When".uppercaseString
        cell.valueLabel.text = session.startDateTimeString
      }
      
      return cell
    } else if indexPath.section == Sections_Current.description {
      let cell = tableView.dequeueReusableCellWithIdentifier("label", forIndexPath: indexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections_Current.presenters {
      let cell = tableView.dequeueReusableCellWithIdentifier("presenter", forIndexPath: indexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person
      
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
  
  func archivedSession_cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == Sections_Archived.description {
      let cell = tableView.dequeueReusableCellWithIdentifier("label", forIndexPath: indexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections_Archived.presenter {
      let cell = tableView.dequeueReusableCellWithIdentifier("presenter", forIndexPath: indexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person
      
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
    } else if indexPath.section == Sections_Archived.presenter {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("presenter", forIndexPath: indexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person
      
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
      
    } else if indexPath.section == Sections_Archived.video {
      
      let cell = tableView.dequeueReusableCellWithIdentifier("video", forIndexPath: indexPath) as! VideoTableViewCell
      cell.videoButton.addTarget(self, action: "showVideoButton:", forControlEvents: .TouchUpInside)
      return cell

    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
      return cell
    }
  }
  
  func roomDetails(sender: UIButton) {
    
    if let roomVC = storyboard?.instantiateViewControllerWithIdentifier("RoomViewController") as? RoomViewController {
      
      roomVC.room = session.room
      roomVC.title = session.room.name
      
      let navController = UINavigationController(rootViewController: roomVC)
      navController.modalPresentationStyle = .FormSheet
      
      presentViewController(navController, animated: true, completion: nil)
    }
  }
  
  func showVideoButton(sender: UIButton) {
  
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navVideoPlayerVC = storyboard.instantiateViewControllerWithIdentifier("NavPlayerViewController") as! UINavigationController
    navVideoPlayerVC.modalPresentationStyle = .FormSheet
    
    let videoPlayerVC = navVideoPlayerVC.topViewController as! AVPlayerViewController
    videoPlayerVC.player = AVPlayer(URL: NSURL(string: session.videoUrl)!)
  
    presentViewController(navVideoPlayerVC, animated: true, completion: nil)
  }
  
  func myScheduleButton(sender: UIButton) {
    session.isFavorite = !session.isFavorite
    
    tableView.reloadSections(NSIndexSet(index: Sections_Current.info), withRowAnimation: .Automatic)
    NSNotificationCenter.defaultCenter().postNotificationName(MyScheduleSomethingChangedNotification, object: self, userInfo: ["session": session])
  }
  
  func twitterButton(sender: UIButton) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/\(sender.titleForState(.Normal)!)")!)
  }
}
