//
//  ScheduleInterfaceController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class ScheduleInterfaceController: WKInterfaceController {
  
  enum State {
    case Loading
    case Empty
    case Loaded([Session])
  }
  
  var state = State.Loading {
    didSet {
      switch state {
      case .Loading:
        table.setNumberOfRows(1, withRowType: "Loading")
      case .Empty:
        table.setNumberOfRows(1, withRowType: "Empty")
      case .Loaded(let sessions):
        table.setNumberOfRows(sessions.count, withRowType: "Session")
        for (index, session) in sessions.enumerate() {
          guard let row = table.rowControllerAtIndex(index) as? SessionRowController else { continue }
          row.session = session
        }
      }
    }
  }
  var schedule: Schedule?
  
  @IBOutlet weak var table: WKInterfaceTable!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    guard let schedule = context as? String else { return }
    self.schedule = Schedule(rawValue: schedule.lowercaseString)
    setTitle(schedule)
  }
  
  override func willActivate() {
    super.willActivate()
    guard let schedule = schedule else { return }
    if !Proxy.defaultProxy.hasCachedSessionsForSchedule(schedule) { state = .Loading }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.state = sessions.count > 0 ? .Loaded(sessions) : .Empty
    }
  }
  
  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    guard segueIdentifier == "Session" else { return nil }
    switch state {
    case .Loading, .Empty:
      return nil
    case .Loaded(let sessions):
      return ["schedule": schedule!.rawValue, "id": sessions[rowIndex].id!]
    }
  }
  
}
