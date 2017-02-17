//
//  EmptyRowController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 25/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class EmptyRowController: NSObject {
  
  @IBOutlet fileprivate weak var messageLabel: WKInterfaceLabel!
  
  var message: String? {
    didSet {
      messageLabel.setText(message)
    }
  }
  
}
