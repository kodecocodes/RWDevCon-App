//
//  WatchDataSource.swift
//  RWDevCon
//
//  Created by Mic Pringle on 07/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import CoreData
import WatchConnectivity

class WatchDataSource: NSObject {
  
    // TODO: these dates?
  fileprivate var predicates = [
    "friday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        Date(timeIntervalSince1970: 1457654400),
        Date(timeIntervalSince1970: 1457740799)
      ]
    ),
    "saturday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        Date(timeIntervalSince1970: 1457740800),
        Date(timeIntervalSince1970: 1457827199)
      ]
    )
  ]
  
  struct Person: Encodable {
    
    let id: String
    let name: String
    
    init(person: RWDevCon.Person) {
      self.id = person.identifier
      self.name = person.fullName
    }
    
    func toJSON() -> JSON? {
      return jsonify([
        "id" ~~> self.id,
        "name" ~~> self.name
      ])
    }
    
  }
  
  struct Session: Encodable {
    
    static var formatter: DateFormatter {
      get {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "US/Eastern")!
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
      }
    }
    
    let date: Date?
    let description: String?
    let duration: Int?
    let id: String?
    let isFavorite: Bool?
    let number: String?
    var presenters: [Person]?
    let room: String?
    let title: String?
    let track: String?
    
    init(session: RWDevCon.Session) {
      self.date = session.date as Date
      self.description = session.sessionDescription
      self.duration = Int(session.duration)
      self.id = session.identifier
      self.isFavorite = session.isFavorite
      self.number = session.sessionNumber
      self.presenters = [Person]()
      self.room = session.room.name
      self.title = session.title
      self.track = session.track.name
      
      guard let presenters = session.presenters.array as? [RWDevCon.Person] else { return }
      presenters.forEach { presenter in
        self.presenters?.append(Person(person: presenter))
      }
    }
    
    func toJSON() -> JSON? {
      return jsonify([
        Encoder.encodeDate("date", dateFormatter: Session.formatter)(self.date),
        "description" ~~> self.description,
        "duration" ~~> self.duration,
        "id" ~~> self.id,
        "isFavorite" ~~> self.isFavorite,
        "number" ~~> self.number,
        "presenters" ~~> Person.toJSONArray(self.presenters ?? [Person]()),
        "room" ~~> self.room,
        "title" ~~> self.title,
        "track" ~~> self.track
      ])
    }
    
  }
  
  let context: NSManagedObjectContext
  var session: WCSession?
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func activate() {
    if WCSession.isSupported() {
      session = WCSession.default()
      session?.delegate = self
      session?.activate()
    }
  }
    
  fileprivate func sesssionsForPredicate(_ predicate: NSPredicate) -> [JSON] {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.predicate = predicate
    fetch.sortDescriptors = [
      NSSortDescriptor(key: "date", ascending: true),
      NSSortDescriptor(key: "track.trackId", ascending: true),
      NSSortDescriptor(key: "column", ascending: true)
    ]
    
    do {
      guard let results = try context.fetch(fetch) as? [RWDevCon.Session] else { return [] }
      var sessions = [Session]()
      results.forEach { session in
        sessions.append(Session(session: session))
      }
      return Session.toJSONArray(sessions) ?? []
    } catch {
      return []
    }
  }
  
  fileprivate func refreshFavoritesPredicate() {
    predicates["favorites"] = NSPredicate(
      format: "active = %@ AND identifier IN %@",
      argumentArray: [
        true,
        Array(Config.favoriteSessions().values)
      ]
    )
  }

}

extension WatchDataSource: WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    refreshFavoritesPredicate()
    guard let schedule = message["schedule"] as? String, let predicate = predicates[schedule] else {
      replyHandler(["sessions": [JSON]()])
      return
    }
    replyHandler(["sessions": sesssionsForPredicate(predicate)])
  }
  
}
