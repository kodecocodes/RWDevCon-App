//
//  VideoViewController.swift
//  RWDevCon
//
//  Created by Pietro Rea on 7/11/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit

class VideoViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  var session: Session!
  
  struct Sections {
    static let description = 0
    static let presenter = 1
    static let video = 1
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
    return 1
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    if section == Sections.description {
      return "Description"
    } else if section == Sections.presenter {
      return "Presenter"
    }
    
    return nil
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
    if indexPath.section == Sections.description {
      let cell = tableView.dequeueReusableCellWithIdentifier("label", forIndexPath: indexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections.presenter {
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
  
  func twitterButton(sender: UIButton) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/\(sender.titleForState(.Normal)!)")!)
  }

}
