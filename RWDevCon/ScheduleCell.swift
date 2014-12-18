//
//  ScheduleCell.swift
//  Schedule
//
//  Created by Mic Pringle on 20/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class ScheduleCell: UICollectionViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var separator: UIView!
  @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint?
  @IBOutlet weak var itemBackgroundView: UIView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let constraint = separatorHeightConstraint {
      constraint.constant = 0.5
    }
    if let view = itemBackgroundView {
      let layer = view.layer
      layer.borderWidth = 1
      layer.borderColor = UIColor(red: 0, green: 104/255, blue: 56/255, alpha: 1).CGColor
      layer.cornerRadius = 4
      layer.masksToBounds = true
    }
  }
  
}
