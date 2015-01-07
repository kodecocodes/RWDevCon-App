//
//  CalendarViewController.swift
//  Schedule
//
//  Created by Mic Pringle on 24/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class CalendarViewController: UICollectionViewController {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let headerNib = UINib(nibName: "ScheduleHeader", bundle: nil)
    collectionView!.registerNib(headerNib, forSupplementaryViewOfKind: "HourHeader", withReuseIdentifier: "ScheduleHeader")
    collectionView!.registerNib(headerNib, forSupplementaryViewOfKind: "TrackHeader", withReuseIdentifier: "ScheduleHeader")
    
    dataSource = collectionView!.dataSource as ScheduleDataSource
    dataSource.startDate = NSDate(timeIntervalSince1970: 1423180800)
    dataSource.endDate = NSDate(timeIntervalSince1970: 1423263600)
    dataSource.coreDataStack = coreDataStack
    dataSource.cellConfigurationBlock = {(cell: ScheduleCell, indexPath: NSIndexPath, session: Session) in
      cell.nameLabel.text = session.title
    }
    dataSource.headerConfigurationBlock = {(header: ScheduleHeader, indexPath: NSIndexPath, group: NSDictionary, kind: String) in
      if kind == "HourHeader" {
        header.titleLabel.text = self.dataSource.titleForHourHeaderViewAtIndexPath(indexPath)
      } else if kind == "TrackHeader" {
        header.titleLabel.text = self.dataSource.titleForTrackHeaderViewAtIndexPath(indexPath)
        if let verticalSeparatorView = header.verticalSeparatorView {
          verticalSeparatorView.hidden = true
        }
      }
    }
    
    navigationController?.interactivePopGestureRecognizer.enabled = false

    NSNotificationCenter.defaultCenter().addObserverForName(SessionDataUpdatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      NSLog("Data was updated, says the notification!")
      self.collectionView?.reloadData()
    }
  }

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView!.collectionViewLayout.invalidateLayout()
  }
  
}
