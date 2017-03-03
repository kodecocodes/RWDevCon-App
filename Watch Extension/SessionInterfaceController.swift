//
//  SessionInterfaceController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class SessionInterfaceController: WKInterfaceController {
  
  @IBOutlet fileprivate weak var titleLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var leftPresenterImage: WKInterfaceImage!
  @IBOutlet fileprivate weak var rightPresenterImage: WKInterfaceImage!
  @IBOutlet fileprivate weak var timeLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var roomLabel: WKInterfaceLabel!
  @IBOutlet fileprivate weak var descriptionLabel: WKInterfaceLabel!
  
  var session: Session? {
    didSet {
      guard let session = session else { return }
      titleLabel.setText(session.title)
      timeLabel.setText(session.time)
      roomLabel.setText(session.room)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.hyphenationFactor = 1
      let description = NSAttributedString(string: session.description!, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
      descriptionLabel.setAttributedText(description)
      guard let presenters = session.presenters else { return }
      for (index, image) in [leftPresenterImage, rightPresenterImage].enumerated() {
        guard index < presenters.count else { break }
        image?.setImage(Avatar.cache.avatarForIdentifier(presenters[index].id))
        image?.setHidden(false)
      }
    }
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    guard let context = context as? [String: String], let rawValue = context["schedule"], let schedule = Schedule(rawValue: rawValue), let id = context["id"] else { return }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.session = sessions.filter { $0.id == id }.first
    }
  }
  
}
