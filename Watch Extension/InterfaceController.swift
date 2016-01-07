//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
  
  override func didAppear() {
    super.didAppear()
    
    let proxy = Proxy()
    proxy.activate()
    proxy.fetchSessions { sessions in
      guard let sessions = sessions else { return }
      print(sessions.count)
    }
  }
  
}
