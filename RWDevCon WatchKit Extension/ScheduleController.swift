
import Foundation
import CoreData
import WatchKit

class ScheduleController: WKInterfaceController {
  @IBOutlet weak var scheduleTable: WKInterfaceTable!
  lazy var coreDataStack = CoreDataStack()
  var sessions = [Session]()
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    if let conferencePlist = NSBundle.mainBundle().URLForResource("RWDevCon2015", withExtension: "plist") {
      Config.loadDataFromPlist(conferencePlist, context: coreDataStack.context)
      coreDataStack.saveContext()
    }

    let fetch = NSFetchRequest(entityName: "Session")
    fetch.predicate = NSPredicate(format: "active = %@", argumentArray: [true])
    fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "track.trackId", ascending: true)]

    if let results = coreDataStack.context.executeFetchRequest(fetch, error: nil) as? [Session] {
      sessions = results

      scheduleTable.setNumberOfRows(results.count, withRowType: "ScheduleRow")

      for (index, session) in enumerate(results) {
        let row = scheduleTable.rowControllerAtIndex(index) as ScheduleRow
        row.rowLabel.setText(session.fullTitle)
      }
    }
  }

  override func willActivate() {
    super.willActivate()
  }

  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    let session = sessions[rowIndex]

    presentControllerWithName("DetailsController", context: session)
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}
