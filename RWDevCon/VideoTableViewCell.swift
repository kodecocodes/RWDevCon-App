//
//  VideoTableViewCell.swift
//  RWDevCon
//
//  Created by Pietro Rea on 7/11/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

  @IBOutlet weak var videoButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    videoButton?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllTouchEvents)
  }
  
}
