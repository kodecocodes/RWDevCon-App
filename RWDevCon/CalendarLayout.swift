//
//  CalendarLayout.swift
//  Schedule
//
//  Created by Mic Pringle on 24/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class CalendarLayout: UICollectionViewLayout {
  
  // MARK: UICollectionViewLayout
    
  override func collectionViewContentSize() -> CGSize {
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    let hoursInSchedule = CGFloat(dataSource.numberOfHoursInSchedule)
    let height = CGRectGetHeight(collectionView!.bounds) - collectionView!.contentInset.top
    let width = dataSource.trackHeaderWidth + (hoursInSchedule * dataSource.widthPerHour)
    return CGSizeMake(width, height)
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    let attributes = NSMutableArray()
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    
    let itemIndexPaths = dataSource.indexPathsOfScheduleItems()
    for indexPath in itemIndexPaths {
      let itemAttributes = layoutAttributesForItemAtIndexPath(indexPath as NSIndexPath)
      attributes.addObject(itemAttributes)
    }
    
    let trackHeaderViewIndexPaths = dataSource.indexPathsOfTrackHeaderViews()
    for indexPath in trackHeaderViewIndexPaths {
      let trackHeaderViewAttributes = layoutAttributesForSupplementaryViewOfKind("TrackHeader", atIndexPath: indexPath as NSIndexPath)
      attributes.addObject(trackHeaderViewAttributes)
    }
    
    let hourHeaderViewIndexPaths = dataSource.indexPathsOfHourHeaderViews()
    for indexPath in hourHeaderViewIndexPaths {
      let hourHeaderViewAttributes = layoutAttributesForSupplementaryViewOfKind("HourHeader", atIndexPath: indexPath as NSIndexPath)
      attributes.addObject(hourHeaderViewAttributes)
    }
    
    return attributes
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    let session = dataSource.sessionForIndexPath(indexPath)
    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
    attributes.frame = frameForSession(session, atIndexPath: indexPath)
    return attributes
  }
  
  override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
    attributes.frame = elementKind == "HourHeader" ? frameForHourHeaderViewAtIndexPath(indexPath) : frameForTrackHeaderViewAtIndexPath(indexPath)
    attributes.zIndex = -1
    return attributes
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
     return true
  }
  
  // MARK: Private Utilities
  
  private func floatValueForKey(key: NSString, inSession session: NSDictionary) -> Float {
    let value = session[key] as NSString
    return value.floatValue
  }
  
  private func frameForHourHeaderViewAtIndexPath(indexPath: NSIndexPath) -> CGRect {
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    let frame = CGRectMake(dataSource.trackHeaderWidth + (dataSource.widthPerHour * CGFloat(indexPath.item)), 0, dataSource.widthPerHour, collectionViewContentSize().height)
    return frame
  }
  
  private func frameForTrackHeaderViewAtIndexPath(indexPath: NSIndexPath) -> CGRect {
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    let heightPerTrack = (collectionViewContentSize().height - dataSource.hourHeaderHeight) / CGFloat(dataSource.numberOfTracksInSchedule)
    let frame = CGRectMake(0, dataSource.hourHeaderHeight + (heightPerTrack * CGFloat(indexPath.item)), dataSource.trackHeaderWidth, heightPerTrack)
    return frame
  }
  
  private func frameForSession(session: Session, atIndexPath indexPath: NSIndexPath) -> CGRect {
    let dataSource = collectionView!.dataSource as ScheduleDataSource
    let heightPerTrack = (collectionViewContentSize().height - dataSource.hourHeaderHeight) / CGFloat(dataSource.numberOfTracksInSchedule)
    let hour = (session.formatDate("H") as NSString).floatValue - Float(dataSource.firstHour)
    let offset = (session.formatDate("m") as NSString).floatValue / 60
    let width = dataSource.widthPerHour * (CGFloat(session.duration) / 60)
    let x = dataSource.trackHeaderWidth + ((CGFloat(hour) * dataSource.widthPerHour) + (dataSource.widthPerHour * CGFloat(offset)))
    let y = dataSource.hourHeaderHeight + (heightPerTrack * CGFloat(indexPath.item))
    let frame = CGRectMake(x, y, width, heightPerTrack)
    return frame
  }
}
