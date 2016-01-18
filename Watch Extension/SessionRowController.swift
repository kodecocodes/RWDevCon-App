//
//  SessionRowController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class SessionRowController: NSObject {
  
  @IBOutlet private weak var trackImage: WKInterfaceImage!
  @IBOutlet private weak var timeLabel: WKInterfaceLabel!
  @IBOutlet private weak var titleLabel: WKInterfaceLabel!
  @IBOutlet private weak var roomLabel: WKInterfaceLabel!
  
  var session: Session? {
    didSet {
      guard let session = session else { return }
      trackImage.setImageNamed(session.track!)
      timeLabel.setText(session.time)
      titleLabel.setText(session.title)
      roomLabel.setText(session.room)
    }
  }
  
}
