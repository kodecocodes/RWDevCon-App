
import Foundation
import CoreData

@objc(Track)
class Track: NSManagedObject {
  @NSManaged var trackId: Int32
  @NSManaged var name: String
  @NSManaged var sessions: NSSet

  class func trackByTrackId(trackId: Int, context: NSManagedObjectContext) -> Track? {
    let fetch = NSFetchRequest(entityName: "Track")
    fetch.predicate = NSPredicate(format: "trackId = %@", argumentArray: [trackId])

    do {
        let results = try context.executeFetchRequest(fetch)
        return results.first as? Track
    } catch let fetchError as NSError {
        print("fetch error: \(fetchError.localizedDescription)")
    }

    return nil
  }

  class func trackByTrackIdOrNew(trackId: Int, context: NSManagedObjectContext) -> Track {
    return trackByTrackId(trackId, context: context) ?? Track(entity: NSEntityDescription.entityForName("Track", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
  }
}
