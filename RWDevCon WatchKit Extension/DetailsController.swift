
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
  }
}
