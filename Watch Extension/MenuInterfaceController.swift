//
//  MenuInterfaceController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class MenuInterfaceController: WKInterfaceController {
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    Proxy.defaultProxy.activate()
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    return segueIdentifier
  }
  
}
