//
//  ScheduleViewController.swift
//  RWDevCon
//
//  Created by Greg Heo on 2015-01-13.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

let bottomHeight: CGFloat = 54

class ScheduleViewController: UIViewController {
  var coreDataStack: CoreDataStack!

  var scheduleTableViewControllers = [ScheduleTableViewController]()

  var bottomView: UIView!
  var contentView: UIView!
  var segmentedControl: UISegmentedControl!

  var firstTime = true

  override func awakeFromNib() {
    super.awakeFromNib()

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
      self.splitViewController?.preferredDisplayMode = .AllVisible
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(red: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)

    let backgroundGrey = UIView()
    backgroundGrey.setTranslatesAutoresizingMaskIntoConstraints(false)
//    backgroundGrey.backgroundColor = UIColor(patternImage: UIImage(named: "pattern")!)
    view.addSubview(backgroundGrey)
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundGrey]|", options: nil, metrics: nil, views: ["backgroundGrey": backgroundGrey]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundGrey]|", options: nil, metrics: nil, views: ["backgroundGrey": backgroundGrey]))

    let friday = NSDate(timeIntervalSince1970: 1423202400)

    let vc1 = storyboard?.instantiateViewControllerWithIdentifier("ScheduleTableViewController") as ScheduleTableViewController
    vc1.coreDataStack = coreDataStack
    vc1.startDate = friday
    scheduleTableViewControllers.append(vc1)

    let vc2 = storyboard?.instantiateViewControllerWithIdentifier("ScheduleTableViewController") as ScheduleTableViewController
    vc2.coreDataStack = coreDataStack
    vc2.startDate = NSDate(timeInterval: 60*60*24, sinceDate: friday)
    scheduleTableViewControllers.append(vc2)

    let vc3 = storyboard?.instantiateViewControllerWithIdentifier("ScheduleTableViewController") as ScheduleTableViewController
    vc3.coreDataStack = coreDataStack
    vc3.startDate = nil
    scheduleTableViewControllers.append(vc3)

    contentView = UIView(frame: view.bounds)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(contentView)
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: nil, metrics: nil, views: ["contentView": contentView]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[contentView]|", options: nil, metrics: nil, views: ["contentView": contentView]))

    bottomView = UIView()
    bottomView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(bottomView)
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomView]|", options: nil, metrics: nil, views: ["bottomView": bottomView]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomView(==bottomHeight)]|", options: nil, metrics: ["bottomHeight": bottomHeight], views: ["bottomView": bottomView]))

    let bottomColor = UIView()
    bottomColor.setTranslatesAutoresizingMaskIntoConstraints(false)
    bottomColor.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.95)
    bottomView.addSubview(bottomColor)
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomColor]|", options: nil, metrics: nil, views: ["bottomColor": bottomColor]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bottomColor]|", options: nil, metrics: nil, views: ["bottomColor": bottomColor]))

    segmentedControl = UISegmentedControl(items: ["Friday", "Saturday", "My Schedule"])
    // TODO: default segment
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.setTranslatesAutoresizingMaskIntoConstraints(false)
    segmentedControl.backgroundColor = UIColor.whiteColor()
    segmentedControl.tintColor = UIColor(red: 0, green: 109.0/255, blue: 55.0/255, alpha: 1.0)
    bottomView.addSubview(segmentedControl)
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: segmentedControl, attribute: .CenterX, relatedBy: .Equal, toItem: bottomView, attribute: .CenterX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1.0, constant: 0),
      ])
    segmentedControl.addTarget(self, action: "segmentChanged:", forControlEvents: .ValueChanged)

    navigationController?.navigationBar.barStyle = UIBarStyle.Default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), forBarMetrics: UIBarMetrics.Default)
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSLog("schedule view controller nav? \(navigationController)")
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewDidLayoutSubviews() {
    if !firstTime {
      return
    }

    firstTime = false

    let vc1 = scheduleTableViewControllers[0]
    let vc2 = scheduleTableViewControllers[1]

    contentView.addSubview(vc2.view)
    addChildViewController(vc2)
    vc2.didMoveToParentViewController(self)

    swapToViewController(vc1, animated: false)
  }

  func segmentChanged(sender: UISegmentedControl) {
    let toVC = scheduleTableViewControllers[sender.selectedSegmentIndex]
    swapToViewController(toVC, animated: false)
  }

  func swapToViewController(toVC: ScheduleTableViewController, animated: Bool = true) {
    var fromVC = childViewControllers.first as? ScheduleTableViewController

    segmentedControl.enabled = false

    if fromVC != nil && fromVC! == toVC {
      fromVC = nil
    }

    if let fromSelected = fromVC?.selectedIndexPath {
      fromVC?.tableView.deselectRowAtIndexPath(fromSelected, animated: false)
      if !splitViewController!.collapsed {
        fromVC?.performSegueWithIdentifier("tableShowDetail", sender: self)
      }
    }

    fromVC?.willMoveToParentViewController(nil)
    addChildViewController(toVC)

    toVC.view.frame = contentView.bounds
    toVC.viewWillAppear(animated)

    if fromVC == nil {
      toVC.isActive = true
      contentView.addSubview(toVC.view)

      toVC.didMoveToParentViewController(self)
      toVC.viewDidAppear(animated)

      if let toSelected = toVC.tableView.indexPathForSelectedRow() {
        toVC.tableView.deselectRowAtIndexPath(toSelected, animated: false)
      }

      self.segmentedControl.enabled = true
    } else {
      UIView.transitionFromView(fromVC!.view, toView: toVC.view, duration: animated ? 0.2 : 0, options: .TransitionCrossDissolve, completion: { (completed) -> Void in
        fromVC!.isActive = false
        toVC.isActive = true

        toVC.didMoveToParentViewController(self)
        toVC.viewDidAppear(animated)
        fromVC!.view.removeFromSuperview()
        fromVC!.removeFromParentViewController()

        if let toSelected = toVC.tableView.indexPathForSelectedRow() {
          toVC.tableView.deselectRowAtIndexPath(toSelected, animated: false)
        }

        self.segmentedControl.enabled = true
      })
    }
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
}
