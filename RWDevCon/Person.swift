
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
  
  class func personByIdentifier(_ identifier: String, context: NSManagedObjectContext) -> Person? {
    // TODO: use Person as type of result
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Person else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func personByIdentifierOrNew(_ identifier: String, context: NSManagedObjectContext) -> Person {
    return personByIdentifier(identifier, context: context) ?? Person(entity: NSEntityDescription.entity(forEntityName: "Person", in: context)!, insertInto: context)
  }
}
