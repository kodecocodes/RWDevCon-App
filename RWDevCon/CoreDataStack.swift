/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import CoreData

public class CoreDataStack {
  
  public let context: NSManagedObjectContext
  let psc: NSPersistentStoreCoordinator
  let model: NSManagedObjectModel
  let store: NSPersistentStore?
  
  public init() {
    let modelName = "RWDevCon"
    
    let bundle = NSBundle.mainBundle()
    let modelURL =
    bundle.URLForResource(modelName, withExtension:"momd")!
    model = NSManagedObjectModel(contentsOfURL: modelURL)!
    
    psc = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    context = NSManagedObjectContext()
    context.persistentStoreCoordinator = psc
    
    let documentsURL = applicationDocumentsDirectory()
    let storeURL = documentsURL.URLByAppendingPathComponent("\(modelName).sqlite")

    NSLog("Store is at \(storeURL)")

    let options = [NSInferMappingModelAutomaticallyOption:true,
        NSMigratePersistentStoresAutomaticallyOption:true]

    var error: NSError? = nil
    store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)

    if store == nil {
      var fileManagerError:NSError? = nil
      let didRemoveStore = NSFileManager.defaultManager().removeItemAtURL(storeURL, error: &fileManagerError)
      if !didRemoveStore {
        println("Error removing persistent store: \(fileManagerError)")
        abort()
      } else {
        println("Model has changed, removing.")
      }
      
      var error: NSError? = nil
      store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)
      if store == nil {
        println("Error adding persistent store: \(error)")
        abort()
      }
    }
  }
  
  func applicationDocumentsDirectory() -> NSURL {
    let fileManager = NSFileManager.defaultManager()
  
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
  
    return urls[0]
  }
  
  func saveContext() {
    var error: NSError? = nil
    if context.hasChanges && !context.save(&error) {
      println("Could not save: \(error), \(error?.userInfo)")
      abort()
    }
  }
  
}

