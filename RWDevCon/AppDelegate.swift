import Foundation
import UIKit
import AVKit
import AVFoundation
import CoreData

// A date before the bundled plist date
private let beginningOfTimeDate = NSDate(timeIntervalSince1970: 1417348800)
// The kill switch date to stop phoning the server
private let endOfTimeDate = NSDate(timeIntervalSince1970: 1423656000)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    if let conferencePlist = NSBundle.mainBundle().URLForResource("RWDevCon2015", withExtension: "plist") {
      if let data = NSDictionary(contentsOfURL: conferencePlist) {
        let localLastUpdatedDate = (Config.userDefaults().objectForKey("lastUpdated") as? NSDate) ?? beginningOfTimeDate
        let plistLastUpdatedDate = (data["metadata"] as! NSDictionary?)?["lastUpdated"] as? NSDate ?? beginningOfTimeDate
        
        // If 0 sessions or the plist is newer, load it!
        if Session.sessionCount(coreDataStack.context) == 0 || localLastUpdatedDate.compare(plistLastUpdatedDate) == NSComparisonResult.OrderedAscending {
          NSLog("Loading from the local plist")
          loadDataFromDictionary(data)
        }
      }
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
    
    return true
  }
  
  func updateFromServer() {
    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://www.raywenderlich.com/downloads/RWDevCon2015_lastUpdate.txt")!,
      completionHandler: { (data, response, error) -> Void in
        if let rawDateString = NSString(data: data!, encoding: NSUTF8StringEncoding) {
          let dateString = rawDateString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
          let formatter = NSDateFormatter()
          formatter.timeZone = NSTimeZone(name: "US/Eastern")!
          formatter.locale = NSLocale(localeIdentifier: "en_US")
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
          if let serverLastUpdatedDate = formatter.dateFromString(dateString) {
            let localLastUpdatedDate = (Config.userDefaults().objectForKey("lastUpdated") as? NSDate) ?? beginningOfTimeDate
            
            if localLastUpdatedDate.compare(serverLastUpdatedDate) == NSComparisonResult.OrderedAscending {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let dict = NSDictionary(contentsOfURL: NSURL(string: "http://www.raywenderlich.com/downloads/RWDevCon2015.plist")!) {
                  let localPlistURL = Config.applicationDocumentsDirectory().URLByAppendingPathComponent("RWDevCon2015-latest.plist")
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
      session.videoUrl = dict["videoUrl"] as? String ?? ""
      session.webPath = dict["webPath"] as? String ?? ""
      
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
  
  func application(application: UIApplication,
    openURL url: NSURL, sourceApplication: String?,
    annotation: AnyObject) -> Bool {
      
      if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true),
        let path = components.path, let query = components.query {
          
          if path == "/videos" {
            //Do something with the query
          }
      }
      
      return false
  }

func application(application: UIApplication,
  continueUserActivity
  userActivity: NSUserActivity,
  restorationHandler: ([AnyObject]?) -> Void) -> Bool {
    
    //1
    if userActivity.activityType ==
      NSUserActivityTypeBrowsingWeb {
        
      let universalURL = userActivity.webpageURL!
      
    //2
      if let components = NSURLComponents(URL: universalURL,
        resolvingAgainstBaseURL: true),
        let path = components.path {
          
          if let session = Session.sessionByWebPath(path,
            context: coreDataStack.context) {
    //3
              let videoURL = NSURL(string: session.videoUrl)!
              presentVideoViewController(videoURL)
          } else {
    //4
            let app = UIApplication.sharedApplication()
            let url = NSURL(string: "http://www.rwdevcon.com")!
            app.openURL(url)
          }
      }
    }
    return true
}
  
  func presentVideoViewController(URL: NSURL) {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navID = "NavPlayerViewController"
    
    let navVideoPlayerVC =
    storyboard.instantiateViewControllerWithIdentifier(navID)
      as! UINavigationController
    
    navVideoPlayerVC.modalPresentationStyle = .FormSheet
    
    let videoPlayerVC = navVideoPlayerVC.topViewController
      as! AVPlayerViewController
    
    videoPlayerVC.player = AVPlayer(URL: URL)
    
    let rootViewController = window!.rootViewController!
    rootViewController.presentViewController(navVideoPlayerVC,
      animated: true, completion: nil)
  }
  
}

extension AppDelegate: UISplitViewControllerDelegate {
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
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
