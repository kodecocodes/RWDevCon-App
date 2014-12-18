//
//  ScheduleDataSource.swift
//  Schedule
//
//  Created by Mic Pringle on 21/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

typealias CellConfigurationBlock = (cell: ScheduleCell, indexPath: NSIndexPath, session: Session) -> ()
typealias HeaderConfigurationBlock = (header: ScheduleHeader, indexPath: NSIndexPath, group: NSDictionary, kind: String) -> ()

class ScheduleDataSource: NSObject, UICollectionViewDataSource {
  var coreDataStack: CoreDataStack!

  var startDate: NSDate?
  var endDate: NSDate?
  var favoritesOnly = false

  let hourHeaderHeight: CGFloat = 40
  let numberOfTracksInSchedule = 3
  let numberOfHoursInSchedule = 11
  let trackHeaderWidth: CGFloat = 120
  let widthPerHour: CGFloat = 180
  let firstHour = 8
  
  var cellConfigurationBlock: CellConfigurationBlock?
  var headerConfigurationBlock: HeaderConfigurationBlock?

  private var allSessions: [Session] {
    let fetch = NSFetchRequest(entityName: "Session")

    if self.startDate != nil && self.endDate != nil {
      fetch.predicate = NSPredicate(format: "(active = %@) AND (date >= %@) AND (date <= %@)", argumentArray: [true, self.startDate!, self.endDate!])
    } else if favoritesOnly {
      fetch.predicate = NSPredicate(format: "active = %@ AND identifier IN %@", argumentArray: [true, Config.favoriteSessions().values.array])
    } else {
      fetch.predicate = NSPredicate(format: "active = %@", argumentArray: [true])
    }
    fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "track.trackId", ascending: true)]

    if let results = self.coreDataStack.context.executeFetchRequest(fetch, error: nil) as? [Session] {
      return results
    }

    return []
  }

  private var distinctTimes: [String] {
    var times = [String]()

    if favoritesOnly {
//      for session in self.allSessions {
//        let last = times.last
//        if (last == nil) || (last != nil && last! != session.formatDate("EEEE")) {
//          times.append(session.formatDate("EEEE"))
//        }
//      }
      times.append("Friday")
      times.append("Saturday")
    } else {
      for session in self.allSessions {
        let last = times.last
        if (last == nil) || (last != nil && last! != session.startDateTimeString) {
          times.append(session.startDateTimeString)
        }
      }
    }

    return times
  }

  private let trackHeaderTitles = ["Beginner", "Intermediate", "Advanced"]
  private let hourHeaderTitles = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00"]
  
  // MARK: UICollectionViewDataSource
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return distinctTimes.count
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfSessionsForSection(section).count;
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ScheduleCell", forIndexPath: indexPath) as ScheduleCell
    let session = sessionForIndexPath(indexPath)
    if let configureBlock = cellConfigurationBlock {
      configureBlock(cell: cell, indexPath: indexPath, session: session)
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ScheduleHeader", forIndexPath: indexPath) as ScheduleHeader
    let group = groupDictionaryForSection(indexPath.section)
    if let configurationBlock = headerConfigurationBlock {
      configurationBlock(header: header, indexPath: indexPath, group: group, kind: kind)
    }
    return header
  }
  
  // MARK: Public Utilites
  
  internal func indexPathsOfHourHeaderViews() -> NSArray {
    let indexPaths = NSMutableArray()
    for item in 0..<numberOfHoursInSchedule {
      let indexPath = NSIndexPath(forItem: item, inSection: 0)
      indexPaths.addObject(indexPath)
    }
    return indexPaths
  }
  
  internal func indexPathsOfScheduleItems() -> NSArray {
    let indexPaths = NSMutableArray()
    for section in 0..<distinctTimes.count {
      let sessions = arrayOfSessionsForSection(section)
      for index in 0..<sessions.count {
          let indexPath = NSIndexPath(forItem: index, inSection: section)
          indexPaths.addObject(indexPath)
      }
    }
    return indexPaths
  }
  
  internal func indexPathsOfTrackHeaderViews() -> NSArray {
    let indexPaths = NSMutableArray()
    for item in 0..<numberOfTracksInSchedule {
      let indexPath = NSIndexPath(forItem: item, inSection: 0)
      indexPaths.addObject(indexPath)
    }
    return indexPaths
  }
    
  internal func sessionForIndexPath(indexPath: NSIndexPath) -> Session {
    let sessions = arrayOfSessionsForSection(indexPath.section)
    return sessions[indexPath.row]
  }
  
  internal func titleForHourHeaderViewAtIndexPath(indexPath: NSIndexPath) -> String {
    return hourHeaderTitles[indexPath.item]
  }
  
  internal func titleForTrackHeaderViewAtIndexPath(indexPath: NSIndexPath) -> String {
    return trackHeaderTitles[indexPath.item]
  }
  
  // MARK: Private Utilities
  
  private func arrayOfSessionsForSection(section: Int) -> [Session] {
    if favoritesOnly {
      let weekday = distinctTimes[section]
      return allSessions.filter({ (session) -> Bool in
        return session.startDateTimeString.hasPrefix(weekday)
      })
    } else {
      let startTimeString = distinctTimes[section]
      return allSessions.filter({ (session) -> Bool in
        return session.startDateTimeString == startTimeString
      })
    }
  }
  
  private func groupDictionaryForSection(section: Int) -> NSDictionary {
    return ["Header": distinctTimes[section]]
  }
  
}