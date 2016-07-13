

import Foundation
import CloudKit
import UIKit

/** To enable extension data sharing, we need to use an app group */
let sharedAppGroup: String = "group.watchGallery"

/** The key for our defaults storage */
let favoritesKey: String = "Favorites"




//
// MARK: - ClouldKitManager
//

/**
 CloudKitManager
 Store in CloudKit and sync with NSUserDefauls in app group
 */
public class CloudKitManager {
  public static let sharedInstance = CloudKitManager()
  
  
  let sharedDefaults: NSUserDefaults?
  var favorites: NSMutableArray?
  
  var container : CKContainer
  var publicDB : CKDatabase
  let privateDB : CKDatabase
  var container2 : CKContainer

  init() {
    container2 = CKContainer(identifier: "iCloud.com.devdesign.WatchGallery")
    sharedDefaults = NSUserDefaults(suiteName: sharedAppGroup)
    container = CKContainer.defaultContainer()
    publicDB = container2.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  

  ///add: add an object to the publicDB
  public func add(object anObject: NSObject, callback:((record: CKRecord?, success: Bool) -> ())?) {

    // Update local list in user defaults
    let current: NSMutableArray = currentList()
    current.addObject(anObject)

    sharedDefaults?.setObject(current, forKey: favoritesKey)
    sharedDefaults?.synchronize()
    
    // Save to ClouldKit
    let record = CKRecord(recordType: "Favorite")
    record.setValue(anObject, forKey: "Name")
    publicDB.saveRecord(record, completionHandler: { (record, error) -> Void in
      if error != nil {
        if error!.code == CKErrorCode.PartialFailure.rawValue {
          print("There was a problem completing the operation. The following records had problems: \(error!.userInfo[CKPartialErrorsByItemIDKey])")
        }
        dispatch_async(dispatch_get_main_queue()) {
          callback?(record: record, success: false)
        }
      } else {
        NSLog("Saved to cloud kit")
        dispatch_async(dispatch_get_main_queue()) {
          callback?(record: record, success: true)
        }
      }
      
      
    })
    
    
  }

  public func currentList() -> NSMutableArray {
   
    var current: NSMutableArray = []
    
   
    if let tempNames: NSArray = sharedDefaults?.arrayForKey(favoritesKey) {
      current = tempNames.mutableCopy() as! NSMutableArray
    }
    return current
  }
  
  ///reset:  reset the objects in the shared defaults
  public func reset() {
    sharedDefaults?.setObject(NSMutableArray(), forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
  
  ///sync: get the data form cloudkit
  public func sync(completion: (results: NSArray) -> Void) {

    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Gallery", predicate: predicate)
    
    publicDB.performQuery(query, inZoneWithID: nil) {
      results, error in
      
      if error != nil {
        completion(results: ["error"])
        print("There is an error:\(error)")
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          let resultsArray = results! as [CKRecord]
          completion(results: resultsArray)
        }
      }
    }
  }
  
}




