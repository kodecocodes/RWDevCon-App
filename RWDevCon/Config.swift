
import Foundation

let SessionDataUpdatedNotification = "com.razeware.rwdevcon.notification.sessionDataUpdated"

class Config {
  class func applicationDocumentsDirectory() -> URL {
    let fileManager = FileManager.default

    if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.razeware.rwdevcon") {
      return containerURL
    }

    let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
    return urls[0]
  }
  
  class func userDefaults() -> UserDefaults {
    return UserDefaults(suiteName: "group.com.razeware.rwdevcon") ?? UserDefaults.standard
  }

  class func favoriteSessions() -> [String: String] {
    if let favs = userDefaults().dictionary(forKey: "favoriteSessions") as? [String: String] {
      return favs
    }
    return [:]
  }
  
  class func nukeFavorites() {
    userDefaults().removeObject(forKey: "favoriteSessions")
    userDefaults().synchronize()
  }
  
  class func registerFavorite(_ session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = session.identifier

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

  class func unregisterFavorite(_ session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = nil

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

}
