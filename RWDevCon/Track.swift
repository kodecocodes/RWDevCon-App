
import Foundation
import CoreData

@objc(Track)
class Track: NSManagedObject {
  @NSManaged var trackId: Int32
  @NSManaged var name: String
  @NSManaged var sessions: NSSet

  class func trackByTrackId(_ trackId: Int, context: NSManagedObjectContext) -> Track? {
    // TODO: Use Track as result type
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
    fetch.predicate = NSPredicate(format: "trackId = %@", argumentArray: [trackId])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Track else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func trackByTrackIdOrNew(_ trackId: Int, context: NSManagedObjectContext) -> Track {
    return trackByTrackId(trackId, context: context) ?? Track(entity: NSEntityDescription.entity(forEntityName: "Track", in: context)!, insertInto: context)
  }
}
