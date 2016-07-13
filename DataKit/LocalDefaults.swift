//
//  LocalDefaults.swift
//  WatchGallery
//
//  Created by Michael on 4/29/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import Foundation


import Foundation
import CloudKit


///DataKitManager:  Protocol to ensure consistancy of data saved to

protocol DataKitManager {
  func add(object anObject: NSObject)
  func reset()
  func currentList() -> NSMutableArray
}


/// LocalDefaultsManager: Store NSUserDefaults in custom app gorup
public class LocalDefaultsManager: DataKitManager {
  
  //MARK: Properties
  public static let sharedInstance = LocalDefaultsManager()
  
  let sharedDefaults: NSUserDefaults?
  var favorites: NSMutableArray?

  init() {
    sharedDefaults = NSUserDefaults(suiteName: sharedAppGroup)
   
  }
  
  ///add:  Add an object to NSUser defaults in app group
  ///-parameters: anObject
  
  public func add(object anObject: NSObject) {

    let current: NSMutableArray = currentList()
    current.addObject(anObject)
    sharedDefaults?.setObject(current, forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
  
  ///currentList: Get the currentlist of NSUserDefaults in App group
  ///-returns: NSMutable Array
  public func currentList() -> NSMutableArray {
    var current: NSMutableArray = []
    if let tempNames: NSArray = sharedDefaults?.arrayForKey(favoritesKey) {
      current = tempNames.mutableCopy() as! NSMutableArray
    }
    return current
  }
  
  ///delete:  Delete an object from the shared app group defaults
  ///-parameters: anObject
  public func delete(anObject: NSObject) {

    let current: NSMutableArray = currentList()
    current.removeObject(anObject)
    sharedDefaults?.setObject(current, forKey: favoritesKey)
    sharedDefaults?.synchronize()
    
  }
  ///reset: remove all objects from NSuser defaults in app gorup
  public func reset() {
    sharedDefaults?.setObject(NSMutableArray(), forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
}