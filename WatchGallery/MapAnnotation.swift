//
//  MapAnnotation.swift
//  WatchGallery
//
//  Created by Michael on 4/29/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import Foundation
import MapKit


/// MapAnnotation: Custom object to hold our custom annotation

class MapAnnotation: NSObject, MKAnnotation {
  let title: String?
  let subtitle: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.subtitle = subtitle
    self.coordinate = coordinate
    
    super.init()
  }
  
}