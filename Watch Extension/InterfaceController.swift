//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
  
  var session: WCSession? {
    didSet {
      guard let session = session else { return }
      session.delegate = self
      session.activateSession()
    }
  }
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if WCSession.isSupported() {
      session = WCSession.defaultSession()
    }
  }
  
  @IBAction func buttonTapped() {
    session?.sendMessage([String: AnyObject](), replyHandler: { results in
      print(results)
    }, errorHandler: { error in
      print(error)
    })
  }
}

extension InterfaceController: WCSessionDelegate {
  
}