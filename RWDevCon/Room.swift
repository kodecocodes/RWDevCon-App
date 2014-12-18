
import Foundation
import CoreData

@objc(Room)
class Room: NSManagedObject {
  @NSManaged var roomId: Int32
  @NSManaged var name: String
  @NSManaged var sessions: NSSet

  class func roomByRoomId(roomId: Int, context: NSManagedObjectContext) -> Room? {
    let fetch = NSFetchRequest(entityName: "Room")
    fetch.predicate = NSPredicate(format: "roomId = %@", argumentArray: [roomId])

    if let results = context.executeFetchRequest(fetch, error: nil) {
      if let result = results.first as? Room {
        return result
      }
    }

    return nil
  }

  class func roomByRoomIdOrNew(roomId: Int, context: NSManagedObjectContext) -> Room {
    return roomByRoomId(roomId, context: context) ?? Room(entity: NSEntityDescription.entityForName("Room", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
  }
}
