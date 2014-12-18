//
//  StickyHeadersViewController.swift
//  Schedule
//
//  Created by Mic Pringle on 20/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class StickyHeadersViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!

  var selectedSession: Session?
  var selectedIndexPath: NSIndexPath?
  var selectedSectionCount = 0

  @IBOutlet weak var segmentedControl: UISegmentedControl!

  // MARK: UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = collectionView!.dataSource as? ScheduleDataSource
    dataSource.coreDataStack = coreDataStack
    // TODO: default segment
    updateDataSourceDates()
    
    dataSource.cellConfigurationBlock = {(cell: ScheduleCell, indexPath: NSIndexPath, session: Session) in
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
      cell.separator.hidden = self.shouldShowSeparatorForIndexPath(indexPath)
    }
    dataSource.headerConfigurationBlock = {(header: ScheduleHeader, indexPath: NSIndexPath, group: NSDictionary, kind: String) in
      let groupHeader = group["Header"] as NSString
      header.titleLabel.text = groupHeader.uppercaseString
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if dataSource.favoritesOnly {
      if selectedIndexPath != nil && selectedSession != nil && !selectedSession!.isFavorite {
        // selected session is no longer a favorite!
        self.collectionView?.deleteItemsAtIndexPaths([self.selectedIndexPath!])
      }

      return
    }

    if let selected = collectionView?.indexPathsForSelectedItems().last as? NSIndexPath {
      collectionView?.reloadSections(NSIndexSet(index: selected.section))
    }
  }

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView!.collectionViewLayout.invalidateLayout()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let dest = segue.destinationViewController as? SessionViewController {
      dest.coreDataStack = coreDataStack
      selectedIndexPath = collectionView!.indexPathsForSelectedItems().last as? NSIndexPath
      selectedSession = dataSource.sessionForIndexPath(collectionView!.indexPathsForSelectedItems().last as NSIndexPath)
      dest.session = selectedSession
    }
  }

  // MARK: Segmented control
  
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    updateDataSourceDates()
    collectionView?.reloadData()
    if dataSource!.numberOfSectionsInCollectionView(self.collectionView!) > 0 && dataSource!.collectionView(self.collectionView!, numberOfItemsInSection: 0) > 0 {
      collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }
  }

  // MARK: UICollectionViewDelegateFlowLayout
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let size = view.bounds.size;
    return CGSizeMake(size.width, 60.0)
  }
  
  // MARK: Private Utilities
  
  private func shouldShowSeparatorForIndexPath(indexPath: NSIndexPath) -> Bool {
    let items = collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: indexPath.section)
    return indexPath.row == (items - 1)
  }

  private func updateDataSourceDates() {
    let friday = NSDate(timeIntervalSince1970: 1423202400)

    if segmentedControl.selectedSegmentIndex == 0 {
      dataSource.startDate = friday
      dataSource.endDate = NSDate(timeInterval: 60*60*24, sinceDate: dataSource.startDate!)
      dataSource.favoritesOnly = false
    } else if segmentedControl.selectedSegmentIndex == 1 {
      dataSource.startDate = NSDate(timeInterval: 60*60*24, sinceDate: friday)
      dataSource.endDate = NSDate(timeInterval: 60*60*24, sinceDate: dataSource.startDate!)
      dataSource.favoritesOnly = false
    } else if segmentedControl.selectedSegmentIndex == 2 {
      dataSource.startDate = nil
      dataSource.endDate = nil
      dataSource.favoritesOnly = true
    }
  }

}
