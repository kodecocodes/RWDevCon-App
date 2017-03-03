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

    if UIDevice.current.userInterfaceIdiom == .pad {
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
      self.splitViewController?.preferredDisplayMode = .allVisible
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(red: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)

    let backgroundGrey = UIView()
    backgroundGrey.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(backgroundGrey)
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundGrey]|", options: nil, metrics: nil, views: ["backgroundGrey": backgroundGrey]))
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundGrey]|", options: nil, metrics: nil, views: ["backgroundGrey": backgroundGrey]))
    
    NSLayoutConstraint.activate([
      backgroundGrey.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundGrey.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundGrey.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundGrey.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    let thursday = Date(timeIntervalSince1970: 1490853600) // WTF Greg!?
    
    let vc0 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc0.coreDataStack = coreDataStack
    vc0.startDate = thursday
    scheduleTableViewControllers.append(vc0)

    let vc1 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc1.coreDataStack = coreDataStack
    vc1.startDate = Date(timeInterval: 60*60*24, since: thursday)
    scheduleTableViewControllers.append(vc1)

    let vc2 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc2.coreDataStack = coreDataStack
    vc2.startDate = Date(timeInterval: 60*60*24*2, since: thursday)
    scheduleTableViewControllers.append(vc2)

    let vc3 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc3.coreDataStack = coreDataStack
    vc3.startDate = nil
    scheduleTableViewControllers.append(vc3)

    contentView = UIView(frame: view.bounds)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: nil, metrics: nil, views: ["contentView": contentView]))
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[contentView]|", options: nil, metrics: nil, views: ["contentView": contentView]))
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    bottomView = UIView()
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bottomView)
    
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomView]|", options: nil, metrics: nil, views: ["bottomView": bottomView]))
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomView(==bottomHeight)]|", options: nil, metrics: ["bottomHeight": bottomHeight], views: ["bottomView": bottomView]))
    
    NSLayoutConstraint.activate([
      bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: bottomHeight),
      bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    let bottomColor = UIView()
    bottomColor.translatesAutoresizingMaskIntoConstraints = false
    bottomColor.backgroundColor = UIColor.white.withAlphaComponent(0.95)
    bottomView.addSubview(bottomColor)
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomColor]|", options: nil, metrics: nil, views: ["bottomColor": bottomColor]))
//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bottomColor]|", options: nil, metrics: nil, views: ["bottomColor": bottomColor]))
    NSLayoutConstraint.activate([
      bottomColor.topAnchor.constraint(equalTo: bottomView.topAnchor),
      bottomColor.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
      bottomColor.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
      bottomColor.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor)
    ])

    let segmentItems = ["Thursday", "Friday", "Saturday", "My Schedule"]
    segmentedControl = UISegmentedControl(items: segmentItems)
    
    
    // attempt to select the current day
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US")
    let weekday = calendar.component(.weekday, from: Date())
    let currentWeekdaySymbol = calendar.weekdaySymbols[weekday - 1]
    segmentedControl.selectedSegmentIndex = segmentItems.index(of: currentWeekdaySymbol) ?? 0
    
    segmentedControl.apportionsSegmentWidthsByContent = true

    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.backgroundColor = UIColor.white
    segmentedControl.tintColor = UIColor(red: 0, green: 109.0/255, blue: 55.0/255, alpha: 1.0)
    bottomView.addSubview(segmentedControl)
    NSLayoutConstraint.activate([
        NSLayoutConstraint(item: segmentedControl, attribute: .leading, relatedBy: .equal, toItem: bottomView, attribute: .leading, multiplier: 1.0, constant: 20),
        NSLayoutConstraint(item: segmentedControl, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1.0, constant: -20),
//      NSLayoutConstraint(item: segmentedControl, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0),
      ])
    segmentedControl.addTarget(self, action: #selector(ScheduleViewController.segmentChanged(_:)), for: .valueChanged)
    

    navigationController?.navigationBar.barStyle = UIBarStyle.default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), for: UIBarMetrics.default)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(true, animated: animated)
    
  }

  override func viewDidLayoutSubviews() {
    if !firstTime {
      return
    }

    firstTime = false

    let scheduleViewToShowAtLaunch = scheduleTableViewControllers[segmentedControl.selectedSegmentIndex]
    swapToViewController(scheduleViewToShowAtLaunch, animated: false)
  }

  func segmentChanged(_ sender: UISegmentedControl) {
    let toVC = scheduleTableViewControllers[sender.selectedSegmentIndex]
    swapToViewController(toVC, animated: false)
  }

  func swapToViewController(_ toVC: ScheduleTableViewController, animated: Bool = true) {
    var fromVC = childViewControllers.first as? ScheduleTableViewController

    segmentedControl.isEnabled = false

    if fromVC != nil && fromVC! == toVC {
      fromVC = nil
    }

    if let fromSelected = fromVC?.selectedIndexPath {
      fromVC?.tableView.deselectRow(at: fromSelected as IndexPath, animated: false)
    }

    fromVC?.willMove(toParentViewController: nil)
    addChildViewController(toVC)

    toVC.view.frame = contentView.bounds
    toVC.viewWillAppear(animated)

    if fromVC == nil {
      toVC.isActive = true
      contentView.addSubview(toVC.view)

      toVC.didMove(toParentViewController: self)
      toVC.viewDidAppear(animated)

      if let toSelected = toVC.tableView.indexPathForSelectedRow {
        toVC.tableView.deselectRow(at: toSelected, animated: false)
      }
      
      self.segmentedControl.isEnabled = true
    } else {
      UIView.transition(from: fromVC!.view, to: toVC.view, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve, completion: { (completed) -> Void in
        fromVC!.isActive = false
        toVC.isActive = true

        toVC.didMove(toParentViewController: self)
        toVC.viewDidAppear(animated)
        fromVC!.view.removeFromSuperview()
        fromVC!.removeFromParentViewController()

        if let toSelected = toVC.tableView.indexPathForSelectedRow {
          toVC.tableView.deselectRow(at: toSelected, animated: false)
        }

        self.segmentedControl.isEnabled = true
      })
    }
  }

  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}
