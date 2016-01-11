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
  
  private let predicates = [
    "friday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        NSDate(timeIntervalSince1970: 1457654400),
        NSDate(timeIntervalSince1970: 1457740799)
      ]
    ),
    "saturday": NSPredicate(
      format: "active = %@ AND (date >= %@) AND (date <= %@)",
      argumentArray: [
        true,
        NSDate(timeIntervalSince1970: 1457740800),
        NSDate(timeIntervalSince1970: 1457827199)
      ]
    ),
    "favourites": NSPredicate(
      format: "active = %@ AND identifier IN %@",
      argumentArray: [
        true,
        Array(Config.favoriteSessions().values)
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
    
    static var formatter: NSDateFormatter {
      get {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "US/Eastern")!
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
      }
    }
    
    let date: NSDate?
    let description: String?
    let duration: Int?
    let id: String?
    let number: String?
    var presenters: [Person]?
    let room: String?
    let title: String?
    let track: String?
    
    init(session: RWDevCon.Session) {
      self.date = session.date
      self.description = session.sessionDescription
      self.duration = Int(session.duration)
      self.id = session.identifier
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
      session = WCSession.defaultSession()
      session?.delegate = self
      session?.activateSession()
    }
  }
    
  private func sesssionsForPredicate(predicate: NSPredicate) -> [JSON] {
    let fetch = NSFetchRequest(entityName: "Session")
    fetch.predicate = predicate
    fetch.sortDescriptors = [
      NSSortDescriptor(key: "date", ascending: true),
      NSSortDescriptor(key: "track.trackId", ascending: true),
      NSSortDescriptor(key: "column", ascending: true)
    ]
    
    do {
      guard let results = try context.executeFetchRequest(fetch) as? [RWDevCon.Session] else { return [] }
      var sessions = [Session]()
      results.forEach { session in
        sessions.append(Session(session: session))
      }
      return Session.toJSONArray(sessions) ?? []
    } catch {
      return []
    }
  }

}

extension WatchDataSource: WCSessionDelegate {
  
  func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
    guard let schedule = message["schedule"] as? String, let predicate = predicates[schedule] else {
      replyHandler(["sessions": [JSON]()])
      return
    }
    replyHandler(["sessions": sesssionsForPredicate(predicate)])
  }
  
}
