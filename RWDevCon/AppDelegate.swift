
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    if let conferencePlist = NSBundle.mainBundle().URLForResource("RWDevCon2015", withExtension: "plist") {
      loadDataFromPlist(conferencePlist)
    }

    ((window?.rootViewController as UINavigationController).topViewController as StickyHeadersViewController).coreDataStack = coreDataStack
    return true
  }

  func loadDataFromPlist(url: NSURL) {
    if let data = NSDictionary(contentsOfURL: url) {
      typealias PlistDict = [String: NSDictionary]

      let metadata: NSDictionary! = data["metadata"] as? NSDictionary
      let sessions: PlistDict! = data["sessions"] as? PlistDict
      let people: PlistDict! = data["people"] as? PlistDict
      let rooms: [String]! = data["rooms"] as? [String]
      let tracks: [String]! = data["tracks"] as? [String]

      if metadata == nil || sessions == nil || people == nil || rooms == nil || tracks == nil {
        return
      }

      let lastUpdated = metadata["lastUpdated"] as? NSDate ?? NSDate(timeIntervalSince1970: 1389528000)

      // TODO: store last updated to NSUserDefaults

      var allRooms = [Room]()
      var allTracks = [Track]()
      var allPeople = [String: Person]()
      
      for (identifier, name) in enumerate(rooms) {
        var room = Room.roomByRoomIdOrNew(identifier, context: coreDataStack.context)

        room.roomId = Int32(identifier)
        room.name = name

        allRooms.append(room)
      }

      for (identifier, name) in enumerate(tracks) {
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
        session.date = dict["date"] as? NSDate ?? NSDate(timeIntervalSince1970: 1389528000)
        session.duration = Int32(dict["duration"] as? Int ?? 0)
        session.column = Int32(dict["column"] as? Int ?? 0)
        session.sessionNumber = dict["sessionNumber"] as? String ?? ""
        session.sessionDescription = dict["sessionDescription"] as? String ?? ""
        session.title = dict["title"] as? String ?? ""

        session.track = allTracks[dict["trackId"] as Int]
        session.room = allRooms[dict["roomId"] as Int]

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
    }
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    coreDataStack.saveContext()
  }

}

