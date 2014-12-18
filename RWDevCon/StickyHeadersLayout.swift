//
//  StickyHeadersLayout.swift
//  Schedule
//
//  Created by Mic Pringle on 20/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class StickyHeadersLayout: UICollectionViewFlowLayout {
  
  // MARK: UICollectionViewFlowLayout
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    
    let superAttributes: NSArray = super.layoutAttributesForElementsInRect(rect)!
    let layoutAttributes = superAttributes.mutableCopy() as NSMutableArray
    
    /*
      
      As UICollectionViewFlowLayout only generates attributes for headers that
      are currently within the collection views' bounds, we need to find any
      missing headers that still require layout manually
    
    */
    let headersNeedingLayout = NSMutableIndexSet()
    
    /* 
      
      Store each section found in the layout attributes array in an index set, so
      we don't have to worry about checking for duplicates
    
    */
    for attributes in layoutAttributes {
      if attributes.representedElementCategory == UICollectionElementCategory.Cell {
        headersNeedingLayout.addIndex(attributes.indexPath!.section)
      }
    }
    
    /*
      
      Remove any sections where the header attributes have already been
      calculated by the call to super
    
    */
    for attributes in layoutAttributes {
      if let elementKind = attributes.representedElementKind? {
        if elementKind == UICollectionElementKindSectionHeader {
          headersNeedingLayout.removeIndex(attributes.indexPath!.section)
        }
      }
    }
    
    /* 
    
      Ask the collection view to generate the attributes for the missing headers
      and add them to the layout attributes array
    
    */
    headersNeedingLayout.enumerateIndexesUsingBlock({ (index, stop) -> Void in
      let indexPath = NSIndexPath(forItem: 0, inSection: index)
      let attributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
      layoutAttributes.addObject(attributes)
    })
    
    /* 
    
      Manually update the layout of all headers in the layout attributes array by
      following these three rule:
       
      1.  The header must be positioned so it is never more than a single header
          height above the first item in its section
      2.  The header must be positioned so its base is never lower than the base
          of the last item in its section
      3.  The header must be positioned so it sticks to the top edge of the
          collection view when not breaking either rule #1 or rule #2
    
    */
    for i in 0..<layoutAttributes.count {
      var attributes = layoutAttributes[i] as UICollectionViewLayoutAttributes
      if let elementKind = attributes.representedElementKind? {
        if elementKind == UICollectionElementKindSectionHeader {
          let section = attributes.indexPath!.section
          if collectionView!.numberOfItemsInSection(section) == 0 {
            continue
          }
          let firstItemAttributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
          let lastItemAttributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: (collectionView!.numberOfItemsInSection(section) - 1), inSection: section))
          let headerFrame = attributes.frame
          let offset = collectionView!.contentOffset.y + collectionView!.contentInset.top
          let yPosition = min(max(offset, CGRectGetMinY(firstItemAttributes.frame) - CGRectGetHeight(headerFrame)), (CGRectGetMaxY(lastItemAttributes.frame) - CGRectGetHeight(headerFrame)))
          attributes.frame = CGRectMake(headerFrame.origin.x, yPosition, CGRectGetWidth(headerFrame), CGRectGetHeight(headerFrame))
          attributes.zIndex = 99
        }
      }
    }
    
    return layoutAttributes
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    
    /*
    
    For sticky headers to work properly, the layout needs to be invalidated 
    whenever the collection view is scrolled. It's ok to do this in this
    scenerio since the calculations above aren't particularly expensive
    
    */
    return true
  }
  
}
