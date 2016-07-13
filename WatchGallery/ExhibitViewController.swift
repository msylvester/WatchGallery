//
//  ExhibitViewController.swift
//  WatchGallery
//
//  Created by Michael on 4/29/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import UIKit
import CoreLocation
import MapKit
import CloudKit
import SafariServices

class ExhibitViewController: UIViewController {

  
  //MARK: Properties
  @IBOutlet weak var exhibitImageOne: UIImageView!
//  @IBOutlet weak var exhibitImageTwo: UIImageView!

  @IBOutlet weak var exhibitDescription:UITextView!

  @IBOutlet weak var galleryNAme: UILabel!
  
  @IBOutlet weak var galleryAddress: UILabel!
  @IBOutlet weak var galleryHours: UILabel!
  
  var exhibitImageInstanceOne = UIImage()
  var exhibitImageInstanceTwo = UIImage()
  var exhibitArtistInstance = ""
  var exhibitArtistName = ""
  var exhibitDescriptionInstance = ""
  var galleryNameInstance = ""
  var galleryAddressInstance = ""
  var galelryHoursInstance = ""
  var recWebsite = ""
  
  weak var record: CKRecord?
  

  override func viewDidLoad() { 
      super.viewDidLoad()
   

  }


  @IBAction func open(sender: AnyObject) {
    
    let svc = SFSafariViewController(URL: NSURL(string: recWebsite)!)
    self.presentViewController(svc, animated: true, completion: nil)
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
   
  }
  
  //on willappear deterime if the CKRecord has all the necessary info and set isntance variables
  override func viewWillAppear(animated: Bool) {
    
    if let _ = record?.objectForKey("CurrentExhibit") as? String, let _ = record?.objectForKey("Artist") as? String, let _ = record?.objectForKey("DescriptionOfExhibit") as? String {
    
      }
    
    
    if let img = record?.valueForKey("ImageUrlOne"), let _ = record?.valueForKey("ImageUrlTwo") {
      exhibitImageOne.image = UIImage(contentsOfFile: img.fileURL.path!)
  
     
    }
    
    if let gallery = record?.objectForKey("NameOFGallery") as? String {
         // galleryName.text = gallery
      galleryNAme.text = gallery
      
      
    }
    
    
    if let hours = record?.objectForKey("OpenTimes") as? String {
      
     // galleryHours.text = hours
      galleryHours.text = hours
    
    }
    
    
    if let address = record?.objectForKey("GalleryAddress") as? String {
      galleryAddress.text = address
   
      
    }
    
    if let website = record?.objectForKey("Website") as? String {
      
      recWebsite = website 
      
    }
  
    
  }


}






