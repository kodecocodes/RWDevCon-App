
import Foundation
import CoreData

@objc(Person)
class Person: NSManagedObject {
  @NSManaged var first: String
  @NSManaged var last: String
  @NSManaged var bio: String
  @NSManaged var twitter: String
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var sessions: NSSet

  var fullName: String {
    return "\(first) \(last)"
  }
  
  class func personByIdentifier(identifier: String, context: NSManagedObjectContext) -> Person? {
    let fetch = NSFetchRequest(entityName: "Person")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])

    do {
        let results = try context.executeFetchRequest(fetch)
        return results.first as? Person
    } catch let fetchError as NSError {
        print("fetch error: \(fetchError.localizedDescription)")
    }

    return nil
  }

  class func personByIdentifierOrNew(identifier: String, context: NSManagedObjectContext) -> Person {
    return personByIdentifier(identifier, context: context) ?? Person(entity: NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
  }
}
