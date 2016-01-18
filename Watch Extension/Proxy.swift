//
//  Proxy.swift
//  RWDevCon
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import WatchConnectivity

enum Schedule: String {
  case Friday = "friday"
  case Saturday = "saturday"
  case Favourites = "favorites"
}

class Proxy: NSObject {
  
  static let defaultProxy = Proxy()
  
  private var session: WCSession?
  private var cache = [Schedule: [Session]]()
  
  func activate() -> Bool {
    guard WCSession.isSupported() else { return false }
    session = WCSession.defaultSession()
    session?.delegate = self
    session?.activateSession()
    return true
  }
  
  func hasCachedSessionsForSchedule(schedule: Schedule) -> Bool {
    guard let _ = cache[schedule] else { return false }
    return true
  }
  
  func sessionsForSchedule(schedule: Schedule, handler: ([Session] -> Void)) {
    if let cached = cache[schedule] {
      handler(cached)
    } else {
      session?.sendMessage(["schedule": schedule.rawValue], replyHandler: { response in
        if let JSON = response["sessions"] as? [JSON], let sessions = Session.modelsFromJSONArray(JSON) {
          if schedule != .Favourites && sessions.count > 0 { self.cache[schedule] = sessions }
          handler(sessions)
        } else {
          handler([])
        }
      }, errorHandler: { error in
        handler([])
      })
    }
  }
  
}

extension Proxy: WCSessionDelegate {}