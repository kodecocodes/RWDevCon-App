import UIKit
import AddressBook
import MapKit
import Contacts

class RoomViewController: UIViewController {
  var room: Room!

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var mapButton: UIButton!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    imageView.image = UIImage(named: room.image)
    descriptionLabel.text = room.roomDescription

    if room.mapLongitude != 0 && room.mapLatitude != 0 {
      mapButton.isHidden = false
    } else {
      mapButton.isHidden = true
    }
  }

  @IBAction func mapButtonTapped(_ sender: AnyObject) {
    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: room.mapLatitude, longitude: room.mapLongitude), addressDictionary: [CNPostalAddressStreetKey: room.mapAddress])
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = room.name
    
    MKMapItem.openMaps(with: [mapItem], launchOptions: [:])
  }
}
