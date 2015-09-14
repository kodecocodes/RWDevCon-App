
import Foundation
import CoreData

private let formatter = NSDateFormatter()

@objc(Session)
class Session: NSManagedObject {
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var title: String
  @NSManaged var date: NSDate
  @NSManaged var duration: Int32
  @NSManaged var column: Int32
  @NSManaged var sessionNumber: String
  @NSManaged var sessionDescription: String
  @NSManaged var room: Room
  @NSManaged var track: Track
  @NSManaged var presenters: NSOrderedSet
  @NSManaged var videoUrl: String
  @NSManaged var webPath: String
  
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
      let favoritesArray = Array(Config.favoriteSessions().values)
      return favoritesArray.indexOf(identifier) != nil
    }
    set {
      if newValue {
        Config.registerFavorite(self)
      } else {
        Config.unregisterFavorite(self)
      }
    }
  }
  
  func formatDate(format: String) -> String {
    formatter.dateFormat = format
    formatter.timeZone = NSTimeZone(name: "US/Eastern")!
    
    return formatter.stringFromDate(date)
  }
  
  class func sessionCount(context: NSManagedObjectContext) -> Int {
    let fetch = NSFetchRequest(entityName: "Session")
    fetch.includesSubentities = false
    return context.countForFetchRequest(fetch, error: nil)
  }
  
  class func sessionByIdentifier(identifier: String, context: NSManagedObjectContext) -> Session? {
    let fetch = NSFetchRequest(entityName: "Session")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    
    do {
      let results = try context.executeFetchRequest(fetch)
      return results.first as? Session
    } catch let fetchError as NSError {
      print("fetch error: \(fetchError.localizedDescription)")
    }
    
    return nil
  }
  
  class func sessionByWebPath(path: String,
    context: NSManagedObjectContext) -> Session? {
      
      let fetch = NSFetchRequest(entityName: "Session")
      fetch.predicate = NSPredicate(format: "webPath = %@",
        argumentArray: [path])
      
      do {
        let results = try context.executeFetchRequest(fetch)
        return results.first as? Session
      } catch let fetchError as NSError {
        print("fetch error: \(fetchError.localizedDescription)")
      }
      
      return nil
  }
  
  class func sessionByIdentifierOrNew(identifier: String, context: NSManagedObjectContext) -> Session {
    return sessionByIdentifier(identifier, context: context) ?? Session(entity: NSEntityDescription.entityForName("Session", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
  }
}
