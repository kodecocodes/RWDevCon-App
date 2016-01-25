//
//  SessionInterfaceController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 11/01/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import WatchKit

class SessionInterfaceController: WKInterfaceController {
  
  @IBOutlet private weak var titleLabel: WKInterfaceLabel!
  @IBOutlet private weak var leftPresenterImage: WKInterfaceImage!
  @IBOutlet private weak var rightPresenterImage: WKInterfaceImage!
  @IBOutlet private weak var timeLabel: WKInterfaceLabel!
  @IBOutlet private weak var roomLabel: WKInterfaceLabel!
  @IBOutlet private weak var descriptionLabel: WKInterfaceLabel!
  
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
      for (index, image) in [leftPresenterImage, rightPresenterImage].enumerate() {
        guard index < presenters.count else { break }
        image.setImage(Avatar.cache.avatarForIdentifier(presenters[index].id))
        image.setHidden(false)
      }
    }
  }
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    guard let context = context as? [String: String], rawValue = context["schedule"], schedule = Schedule(rawValue: rawValue), id = context["id"] else { return }
    Proxy.defaultProxy.sessionsForSchedule(schedule) { sessions in
      self.session = sessions.filter { $0.id == id }.first
    }
  }
  
}
