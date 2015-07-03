
import UIKit
import AddressBook
import MapKit

class AboutViewController: UIViewController {
  @IBOutlet weak var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // #e6e6e6
    view.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)

    do {
      let htmlString = try NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("about", ofType: "html")!, encoding: NSUTF8StringEncoding)
      webView.loadHTMLString(htmlString as String, baseURL: NSBundle.mainBundle().bundleURL)
    } catch _ {
      
    }
    
  }
}

extension AboutViewController: UIWebViewDelegate {
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if request.URL!.absoluteString as String == "rwdevcon://location" {
      
      let addressDictionary =
      [kABPersonAddressStreetKey as String: "415 New Jersey Avenue Northwest",
        kABPersonAddressCityKey as String: "Washington",
        kABPersonAddressStateKey as String: "DC",
        kABPersonAddressZIPKey as String: "20001",
        kABPersonAddressCountryCodeKey as String: "US"]
      
      let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 38.895518, longitude: -77.010729), addressDictionary: addressDictionary)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = "RWDevCon"

      MKMapItem.openMapsWithItems([mapItem], launchOptions: [:])

      return false
    }

    return true
  }
}
