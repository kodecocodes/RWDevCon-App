
import Foundation
import CoreData

private let formatter = DateFormatter()

@objc(Session)
class Session: NSManagedObject {
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var title: String
  @NSManaged var date: Date
  @NSManaged var duration: Int32
  @NSManaged var column: Int32
  @NSManaged var sessionNumber: String
  @NSManaged var sessionDescription: String
  @NSManaged var room: Room
  @NSManaged var track: Track
  @NSManaged var presenters: NSOrderedSet

  var fullTitle: String {
    return (sessionNumber != "" ? "\(sessionNumber): " : "") + title
  }

  var startDateDayOfWeek: String {
    return formatDate("EEEE")
  }

  var startDateTimeString: String {
    return formatDate("EEEE h:mm a")
  }

  var startTimeString: String {
    return formatDate("h:mm a")
  }

  var isFavorite: Bool {
    get {
      let favorites = Config.favoriteSessions()
      return Array(favorites.values).contains(identifier)
    }
    set {
      if newValue {
        Config.registerFavorite(self)
      } else {
        Config.unregisterFavorite(self)
      }
    }
  }
  
  var isParty: Bool {
    return title.lowercased().contains("party")
  }

  func formatDate(_ format: String) -> String {
    // TODO: more efficient way than setting the format each time?
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(identifier: "US/Eastern")!

    return formatter.string(from: date)
  }

  class func sessionCount(_ context: NSManagedObjectContext) -> Int {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.includesSubentities = false
    return (try? context.count(for: fetch)) ?? 0
  }

  class func sessionByIdentifier(_ identifier: String, context: NSManagedObjectContext) -> Session? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Session else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func sessionByIdentifierOrNew(_ identifier: String, context: NSManagedObjectContext) -> Session {
    return sessionByIdentifier(identifier, context: context) ?? Session(entity: NSEntityDescription.entity(forEntityName: "Session", in: context)!, insertInto: context)
  }
}
