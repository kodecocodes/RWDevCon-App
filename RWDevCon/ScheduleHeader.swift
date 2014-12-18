//
//  ScheduleHeader.swift
//  Schedule
//
//  Created by Mic Pringle on 20/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

class ScheduleHeader: UICollectionReusableView {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var verticalSeparatorView: UIView?
  @IBOutlet weak var verticalSeparatorViewWidthConstraint: NSLayoutConstraint?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if let verticalConstraint = verticalSeparatorViewWidthConstraint {
      verticalConstraint.constant = 0.5
    }
  }
  
}
