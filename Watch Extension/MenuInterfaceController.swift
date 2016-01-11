//
//  MenuInterfaceController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class MenuInterfaceController: WKInterfaceController {
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    Proxy.defaultProxy.activate()
  }
  
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    return segueIdentifier
  }
  
}
