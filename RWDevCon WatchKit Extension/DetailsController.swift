
import Foundation
import WatchKit

class DetailsController: WKInterfaceController {

  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var image: WKInterfaceImage!
  @IBOutlet weak var detailsLabel: WKInterfaceLabel!

  override func awakeWithContext(context: AnyObject?) {
    if let session = context as? Session {
      titleLabel.setText(session.fullTitle)
      detailsLabel.setText("\(session.startDateTimeString)\n\(session.sessionDescription)")
      image.setHidden(true)
    }

    if let person = context as? Person {
      titleLabel.setText(person.fullName)
      detailsLabel.setText(person.bio)
      if let avatar = UIImage(named: person.identifier) {
        image.setImage(avatar)
      } else {
        image.setHidden(true)
      }
    }
  }
}
