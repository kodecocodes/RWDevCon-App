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
  
  let proxy = Proxy()
  
  override func didAppear() {
    super.didAppear()
    
    proxy.activate()
    
    
  }
  
  @IBAction func go() {
    
    proxy.sessionsForSchedule(.Saturday) { sessions in
      print(sessions.count)
    }
    
  }
}
