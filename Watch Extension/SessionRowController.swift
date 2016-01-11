//
//  SessionRowController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class SessionRowController: NSObject {
  
  @IBOutlet private weak var titleLabel: WKInterfaceLabel!
  
  var session: Session? {
    didSet {
      guard let session = session else { return }
      titleLabel.setText(session.title)
    }
  }
  
}
