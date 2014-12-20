
import Foundation
import CoreData

class Config {
  /** Get the user defaults object */
  class func userDefaults() -> NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  /** Load conference data from a plist into Core Data */
  class func loadDataFromPlist(url: NSURL, context: NSManagedObjectContext) {
    if let data = NSDictionary(contentsOfURL: url) {
      typealias PlistDict = [String: NSDictionary]

      let metadata: NSDictionary! = data["metadata"] as? NSDictionary
      let sessions: PlistDict! = data["sessions"] as? PlistDict
      let people: PlistDict! = data["people"] as? PlistDict
      let rooms: [String]! = data["rooms"] as? [String]
      let tracks: [String]! = data["tracks"] as? [String]

      if metadata == nil || sessions == nil || people == nil || rooms == nil || tracks == nil {
        return
      }

      let lastUpdated = metadata["lastUpdated"] as? NSDate ?? NSDate(timeIntervalSince1970: 1389528000)

      // TODO: store last updated to NSUserDefaults

      var allRooms = [Room]()
      var allTracks = [Track]()
      var allPeople = [String: Person]()

      for (identifier, name) in enumerate(rooms) {
        var room = Room.roomByRoomIdOrNew(identifier, context: context)

        room.roomId = Int32(identifier)
        room.name = name

        allRooms.append(room)
      }

      for (identifier, name) in enumerate(tracks) {
        let track = Track.trackByTrackIdOrNew(identifier, context: context)

        track.trackId = Int32(identifier)
        track.name = name

        allTracks.append(track)
      }

      for (identifier, dict) in people {
        let person = Person.personByIdentifierOrNew(identifier, context: context)

        person.identifier = identifier
        person.first = dict["first"] as? String ?? ""
        person.last = dict["last"] as? String ?? ""
        person.active = dict["active"] as? Bool ?? false
        person.twitter = dict["twitter"] as? String ?? ""
        person.bio = dict["bio"] as? String ?? ""

        allPeople[identifier] = person
      }

      for (identifier, dict) in sessions {
        let session = Session.sessionByIdentifierOrNew(identifier, context: context)

        session.identifier = identifier
        session.active = dict["active"] as? Bool ?? false
        session.date = dict["date"] as? NSDate ?? NSDate(timeIntervalSince1970: 1389528000)
        session.duration = Int32(dict["duration"] as? Int ?? 0)
        session.column = Int32(dict["column"] as? Int ?? 0)
        session.sessionNumber = dict["sessionNumber"] as? String ?? ""
        session.sessionDescription = dict["sessionDescription"] as? String ?? ""
        session.title = dict["title"] as? String ?? ""

        session.track = allTracks[dict["trackId"] as Int]
        session.room = allRooms[dict["roomId"] as Int]

        var presenters = [Person]()
        if let rawPresenters = dict["presenters"] as? [String] {
          for presenter in rawPresenters {
            if let person = allPeople[presenter] {
              presenters.append(person)
            }
          }
        }
        session.presenters = NSOrderedSet(array: presenters)
      }
    }
  }

  /** Get a list of all favorite sessions. Keys are the start date time string and values are the session identifiers */
  class func favoriteSessions() -> [String: String] {
    if let favs = userDefaults().dictionaryForKey("favoriteSessions") as? [String: String] {
      return favs
    }
    return [:]
  }

  /** Register a session as a favorite. Note that only one session per time slot can be favorited! */
  class func registerFavorite(session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = session.identifier

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

  /** Unregister a session as a favorite */
  class func unregisterFavorite(session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = nil

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

}
