//
//  ScheduleTableViewCell.swift
//  RWDevCon
//
//  Created by Greg Heo on 2015-01-13.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
