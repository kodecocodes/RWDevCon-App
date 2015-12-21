import UIKit
import AddressBook
import MapKit
import Contacts

class AboutViewController: UIViewController {
  @IBOutlet weak var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // #e6e6e6
    view.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)

    do {
      let htmlString = try NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("about", ofType: "html")!, encoding: NSUTF8StringEncoding) as String
      webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
    } catch {
     return
    }
  }
}

extension AboutViewController: UIWebViewDelegate {
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    guard let url = request.URL else { return true }
    if url.absoluteString == "rwdevcon://location" {
      let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 38.895518, longitude: -77.010729), addressDictionary: [CNPostalAddressStreetKey: "415 New Jersey Avenue Northwest", CNPostalAddressCityKey: "Washington", CNPostalAddressStateKey: "DC", CNPostalAddressPostalCodeKey: "20001", CNPostalAddressCountryKey: "US"])
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = "RWDevCon"
      MKMapItem.openMapsWithItems([mapItem], launchOptions: [:])
      return false
    }
    return true
  }
}
