
import Foundation
import CoreData

@objc(Room)
class Room: NSManagedObject {
  @NSManaged var roomId: Int32
  @NSManaged var name: String
  @NSManaged var roomDescription: String
  @NSManaged var sessions: NSSet
  @NSManaged var image: String
  @NSManaged var mapAddress: String
  @NSManaged var mapLatitude: Double
  @NSManaged var mapLongitude: Double

  class func roomByRoomId(_ roomId: Int, context: NSManagedObjectContext) -> Room? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
    fetch.predicate = NSPredicate(format: "roomId = %@", argumentArray: [roomId])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Room else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func roomByRoomIdOrNew(_ roomId: Int, context: NSManagedObjectContext) -> Room {
    return roomByRoomId(roomId, context: context) ?? Room(entity: NSEntityDescription.entity(forEntityName: "Room", in: context)!, insertInto: context)
  }
}
