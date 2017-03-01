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
    case loading
    case empty
    case loaded([Session])
  }
  
  var state = State.loading {
    didSet {
      switch state {
      case .loading:
        table.setNumberOfRows(1, withRowType: "Loading")
      case .empty:
        table.setNumberOfRows(1, withRowType: "Empty")
        guard let schedule = schedule, let row = table.rowController(at: 0) as? EmptyRowController else { return }
        switch schedule {
        case .favorites:
          row.message = "Failed to load your schedule. Please make sure you have added some sessions, and your phone is within range."
        case .thursday, .friday, .saturday:
          row.message = "Failed to load the schedule. Please make sure your phone is within range."
        }
      case .loaded(let sessions):
        table.setNumberOfRows(sessions.count, withRowType: "Session")
        for (index, session) in sessions.enumerated() {
          guard let row = table.rowController(at: index) as? SessionRowController else { continue }
          row.session = session
        }
      }
    }
  }
  var schedule: Schedule?
  
  @IBOutlet weak var table: WKInterfaceTable!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let schedule = context as? String else { return }
    self.schedule = Schedule(rawValue: schedule.lowercased())
    setTitle(schedule == "Favorites" ? "My Schedule" : schedule)
  }
  
  override func willActivate() {
    super.willActivate()
    guard let schedule = schedule else { return }
    if !Proxy.defaultProxy.hasCachedSessionsForSchedule(schedule) { state = .loading }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.state = sessions.count > 0 ? .loaded(sessions) : .empty
    }
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    guard segueIdentifier == "Session" else { return nil }
    switch state {
    case .loading, .empty:
      return nil
    case .loaded(let sessions):
      return ["schedule": schedule!.rawValue, "id": sessions[rowIndex].id!]
    }
  }
  
  deinit {
    if let schedule = schedule, schedule == .favorites {
      Proxy.defaultProxy.removeSessionsForSchedule(.favorites)
    }
  }
  
}
