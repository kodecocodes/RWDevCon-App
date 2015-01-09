
import UIKit
import AddressBook
import MapKit

class AboutViewController: UIViewController {
  @IBOutlet weak var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // #e6e6e6
    view.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)

    let htmlString = NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("about", ofType: "html")!, encoding: NSUTF8StringEncoding, error: nil)
    webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
  }
}

extension AboutViewController: UIWebViewDelegate {
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if request.URL.absoluteString! == "rwdevcon://location" {
      let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 38.895518, longitude: -77.010729), addressDictionary: [kABPersonAddressStreetKey: "415 New Jersey Avenue Northwest", kABPersonAddressCityKey: "Washington", kABPersonAddressStateKey: "DC", kABPersonAddressZIPKey: "20001", kABPersonAddressCountryCodeKey: "US"])
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = "RWDevCon"

      MKMapItem.openMapsWithItems([mapItem], launchOptions: [:])

      return false
    }

    return true
  }
}
