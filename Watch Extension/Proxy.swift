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
  case thursday = "thursday"
  case friday = "friday"
  case saturday = "saturday"
  case favorites = "favorites"
}

class Proxy: NSObject {
  
  static let defaultProxy = Proxy()
  
  fileprivate var session: WCSession?
  fileprivate var cache = [Schedule: [Session]]()
  
  func activate() -> Bool {
    guard WCSession.isSupported() else { return false }
    session = WCSession.default()
    session?.delegate = self
    session?.activate()
    return true
  }
  
  func hasCachedSessionsForSchedule(_ schedule: Schedule) -> Bool {
    guard let _ = cache[schedule] else { return false }
    return true
  }
  
  func removeSessionsForSchedule(_ schedule: Schedule) {
    cache.removeValue(forKey: schedule)
  }
  
  func sessionsForSchedule(_ schedule: Schedule, handler: @escaping (([Session]) -> Void)) {
    if let cached = cache[schedule] {
      handler(cached)
    } else {
      session?.sendMessage(["schedule": schedule.rawValue], replyHandler: { response in
        if let JSON = response["sessions"] as? [JSON], let sessions = [Session].from(jsonArray: JSON) {
          if sessions.count > 0 { self.cache[schedule] = sessions }
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

extension Proxy: WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
