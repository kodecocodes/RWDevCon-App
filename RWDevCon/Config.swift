
import Foundation

class Config {
  class func userDefaults() -> NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  class func favoriteSessions() -> [String: String] {
    if let favs = userDefaults().dictionaryForKey("favoriteSessions") as? [String: String] {
      return favs
    }
    return [:]
  }

  class func registerFavorite(session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = session.identifier

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

  class func unregisterFavorite(session: Session) {
    var favs = favoriteSessions()
    favs[session.startDateTimeString] = nil

    userDefaults().setValue((favs as NSDictionary), forKey: "favoriteSessions")
    userDefaults().synchronize()
  }

}
