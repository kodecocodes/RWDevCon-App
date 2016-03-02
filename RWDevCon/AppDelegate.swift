import Foundation
import UIKit
import CoreData

// A date before the bundled plist date
private let beginningOfTimeDate = NSDate(timeIntervalSince1970: 1456876800) // 02-03-2016 12:00 AM
// The kill switch date to stop phoning the server
private let endOfTimeDate = NSDate(timeIntervalSince1970: 1457827199) // 12-03-2016 11:59 PM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()
  var watchDataSource: WatchDataSource?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    guard let plist = NSBundle.mainBundle().URLForResource("RWDevCon2016", withExtension: "plist"), let data = NSDictionary(contentsOfURL: plist) else { return true }
    
    resetIfNeeded()
    
    let localLastUpdateDate = Config.userDefaults().objectForKey("lastUpdated") as? NSDate ?? beginningOfTimeDate
    let plistLastUpdateDate = data["metadata"]?["lastUpdated"] as? NSDate ?? beginningOfTimeDate
    if Session.sessionCount(coreDataStack.context) == 0 || localLastUpdateDate.compare(plistLastUpdateDate) == .OrderedAscending {
      loadDataFromDictionary(data)
    }
  
    // global style
    application.statusBarStyle = UIStatusBarStyle.LightContent
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
    
    let splitViewController = self.window!.rootViewController as! UISplitViewController
    splitViewController.delegate = self

    let navigationController = splitViewController.viewControllers[0] as! UINavigationController
    (navigationController.topViewController as! ScheduleViewController).coreDataStack = coreDataStack

    let detailWrapperController = splitViewController.viewControllers[1] as! UINavigationController
    (detailWrapperController.topViewController as! SessionViewController).coreDataStack = coreDataStack
    
    watchDataSource = WatchDataSource(context: coreDataStack.context)
    watchDataSource?.activate()
    
    return true
  }
  
  func resetIfNeeded() {
    let resetForNextConferenceKey = "reset-for-2016"
    if !Config.userDefaults().boolForKey(resetForNextConferenceKey) {
      let storeURL = Config.applicationDocumentsDirectory().URLByAppendingPathComponent("\(CoreDataStack.modelName).sqlite")
      do {
        try NSFileManager.defaultManager().removeItemAtURL(storeURL)
      } catch { /* Don't need to do anything here; an error simply means the store didn't exist in the first place */ }
      Config.nukeFavorites()
      Config.userDefaults().setBool(true, forKey: resetForNextConferenceKey)
    }
  }
  
  func updateFromServer() {
    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://www.raywenderlich.com/downloads/RWDevCon2016_lastUpdate.txt")!,
      completionHandler: { (data, response, error) -> Void in
        guard let data = data else { return }
        if let rawDateString = NSString(data: data, encoding: NSUTF8StringEncoding) {
          let dateString = rawDateString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
          let formatter = NSDateFormatter()
          formatter.timeZone = NSTimeZone(name: "US/Eastern")!
          formatter.locale = NSLocale(localeIdentifier: "en_US")
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
          if let serverLastUpdatedDate = formatter.dateFromString(dateString) {
            let localLastUpdatedDate = (Config.userDefaults().objectForKey("lastUpdated") as? NSDate) ?? beginningOfTimeDate

            if localLastUpdatedDate.compare(serverLastUpdatedDate) == NSComparisonResult.OrderedAscending {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let dict = NSDictionary(contentsOfURL: NSURL(string: "http://www.raywenderlich.com/downloads/RWDevCon2016.plist")!) {
                  let localPlistURL = Config.applicationDocumentsDirectory().URLByAppendingPathComponent("RWDevCon2016-latest.plist")
                  dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSLog("New data from remote! local \(localLastUpdatedDate) server \(serverLastUpdatedDate)")
                    
                    dict.writeToURL(localPlistURL, atomically: true)
                    self.loadDataFromDictionary(dict)
                  })
                }
              })
            } else {
              NSLog("No new data from remote: local \(localLastUpdatedDate) server \(serverLastUpdatedDate)")
            }

            Config.userDefaults().setObject(NSDate(), forKey: "lastServerCheck")
            Config.userDefaults().synchronize()
          }
        }
    })
    task.resume()
  }

  func loadDataFromPlist(url: NSURL) {
    if let data = NSDictionary(contentsOfURL: url) {
      loadDataFromDictionary(data)
    }
  }

  func loadDataFromDictionary(data: NSDictionary) {
    typealias PlistDict = [String: NSDictionary]
    typealias PlistArray = [NSDictionary]

    let metadata: NSDictionary! = data["metadata"] as? NSDictionary
    let sessions: PlistDict! = data["sessions"] as? PlistDict
    let people: PlistDict! = data["people"] as? PlistDict
    let rooms: PlistArray! = data["rooms"] as? PlistArray
    let tracks: [String]! = data["tracks"] as? [String]

    if metadata == nil || sessions == nil || people == nil || rooms == nil || tracks == nil {
      return
    }

    let lastUpdated = metadata["lastUpdated"] as? NSDate ?? beginningOfTimeDate
    Config.userDefaults().setObject(lastUpdated, forKey: "lastUpdated")

    var allRooms = [Room]()
    var allTracks = [Track]()
    var allPeople = [String: Person]()

    for (identifier, dict) in rooms.enumerate() {
      let room = Room.roomByRoomIdOrNew(identifier, context: coreDataStack.context)

      room.roomId = Int32(identifier)
      room.name = dict["name"] as? String ?? ""
      room.image = dict["image"] as? String ?? ""
      room.roomDescription = dict["roomDescription"] as? String ?? ""
      room.mapAddress = dict["mapAddress"] as? String ?? ""
      room.mapLatitude = dict["mapLatitude"] as? Double ?? 0
      room.mapLongitude = dict["mapLongitude"] as? Double ?? 0

      allRooms.append(room)
    }

    for (identifier, name) in tracks.enumerate() {
      let track = Track.trackByTrackIdOrNew(identifier, context: coreDataStack.context)

      track.trackId = Int32(identifier)
      track.name = name

      allTracks.append(track)
    }

    for (identifier, dict) in people {
      let person = Person.personByIdentifierOrNew(identifier, context: coreDataStack.context)

      person.identifier = identifier
      person.first = dict["first"] as? String ?? ""
      person.last = dict["last"] as? String ?? ""
      person.active = dict["active"] as? Bool ?? false
      person.twitter = dict["twitter"] as? String ?? ""
      person.bio = dict["bio"] as? String ?? ""

      allPeople[identifier] = person
    }

    for (identifier, dict) in sessions {
      let session = Session.sessionByIdentifierOrNew(identifier, context: coreDataStack.context)

      session.identifier = identifier
      session.active = dict["active"] as? Bool ?? false
      session.date = dict["date"] as? NSDate ?? beginningOfTimeDate
      session.duration = Int32(dict["duration"] as? Int ?? 0)
      session.column = Int32(dict["column"] as? Int ?? 0)
      session.sessionNumber = dict["sessionNumber"] as? String ?? ""
      session.sessionDescription = dict["sessionDescription"] as? String ?? ""
      session.title = dict["title"] as? String ?? ""

      session.track = allTracks[dict["trackId"] as! Int]
      session.room = allRooms[dict["roomId"] as! Int]

      var presenters = [Person]()
      if let rawPresenters = dict["presenters"] as? [String] {
        for presenter in rawPresenters {
          if let person = allPeople[presenter] {
            presenters.append(person)
          }
        }
      }
      session.presenters = NSOrderedSet(array: presenters)
    }

    coreDataStack.saveContext()

    NSNotificationCenter.defaultCenter().postNotificationName(SessionDataUpdatedNotification, object: self)
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // kick off the background refresh from the server if hasn't been too soon
    let tooSoonSeconds: NSTimeInterval = 60 * 30 // how many seconds is too soon?
    if endOfTimeDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
      let lastServerCheck = Config.userDefaults().valueForKey("lastServerCheck") as? NSDate ?? beginningOfTimeDate
      if NSDate().timeIntervalSinceDate(lastServerCheck) > tooSoonSeconds {
        NSLog("Checking with the server at \(NSDate()); last check was \(lastServerCheck)")
        updateFromServer()
      } else {
        NSLog("NOT checking with the server at \(NSDate()); last check was \(lastServerCheck)")
      }
    }
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    coreDataStack.saveContext()
  }

}

extension AppDelegate: UISplitViewControllerDelegate {
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
      if let topAsDetailController = secondaryAsNavController.topViewController as? SessionViewController {
        if topAsDetailController.session == nil {
          // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
          return true
        }
      }
    }
    return false
  }

}
