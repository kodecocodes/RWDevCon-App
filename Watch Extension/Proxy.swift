//
//  Proxy.swift
//  RWDevCon
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import WatchConnectivity

class Proxy: NSObject {
  
  private var session: WCSession?
  
  func activate() -> Bool {
    guard WCSession.isSupported() else { return false }
    session = WCSession.defaultSession()
    session?.delegate = self
    session?.activateSession()
    return true
  }
  
  // Test method only. Should fetch by day, or favorite, and cache
  func fetchSessions(handler: ([Session]? -> Void)) {
    session?.sendMessage(["fetch": "sessions"], replyHandler: { results in
      if let sessions = results["sessions"] as? [JSON] {
        handler(Session.modelsFromJSONArray(sessions))
      } else {
        handler(nil)
      }
    }, errorHandler: { error in
      handler(nil)
    })
  }
  
}

extension Proxy: WCSessionDelegate {}