
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

    showAllSessions()
  }

  override func willActivate() {
    super.willActivate()
  }

  private func showAllSessions() {
    sessions = Session.allSessionsInContext(coreDataStack.context)
    refreshTable()
  }

  private func refreshTable() {
    scheduleTable.setNumberOfRows(sessions.count, withRowType: "ScheduleRow")

    for (index, session) in enumerate(sessions) {
      let row = scheduleTable.rowControllerAtIndex(index) as ScheduleRow
      row.rowLabel.setText(session.fullTitle)
      row.dateLabel.setText(session.startDateTimeShortString)

      row.image.setHidden(true)
      if session.track.name == "Beginner" {
        row.image.setHidden(false)
        row.image.setImageNamed("beginner")
      } else if session.track.name == "Intermediate" {
        row.image.setHidden(false)
        row.image.setImageNamed("intermediate")
      } else if session.track.name == "Advanced" {
        row.image.setHidden(false)
        row.image.setImageNamed("advanced")
      }
    }
  }

  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    let session = sessions[rowIndex]
    let presenters = session.presenters.array

    presentControllerWithNames(Array<String>(count: presenters.count + 1, repeatedValue: "DetailsController") , contexts: [session] + presenters)
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}
