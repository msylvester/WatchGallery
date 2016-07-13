//
//  RecentTableViewController.swift
//  WatchGallery
//
//  Created by Michael on 4/27/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import CloudKit
import DataKit
import MapKit
import CoreLocation


///RecentTableViewController:  The root view for the tabviewcontroller
class RecentTableViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
    //MARK: Properties
    var records = [CKRecord]()
    var localRecords = [CKRecord]()
    let locationManager = CLLocationManager()
    var totalDistance = 0.0
    var currentLocation = CLLocation()
    let container = UIView()
  
    var filteredRecords = [CKRecord]()
  
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        super.viewDidLoad()

    }

  override func viewWillAppear(animated: Bool) {
    
    self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
    

    
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    refreshTable()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }


  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return localRecords.count
  }
  
  //MARK: Data source
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cellRecent", forIndexPath: indexPath) as? RecentTableViewCell
    self.configureCell(cell!, atIndexPath: indexPath)
    return cell!
  }
  

  ///ConfigureCell:  Set the properites of the cell
  func configureCell(cell: RecentTableViewCell, atIndexPath indexPath: NSIndexPath) {
    
    let favoriteRecord = localRecords[indexPath.row]
    cell.record = localRecords[indexPath.row]
    cell.galleryLabel.text = favoriteRecord.objectForKey("NameOFGallery") as? String
    let meters = CLLocationDistance(currentLocation.distanceFromLocation((favoriteRecord.objectForKey("Location") as? CLLocation)!))
    let miles = meters*0.000621371
    var mi_text = String(format: "%.2f", miles)
    mi_text = mi_text + "mi."
    cell.artistLabel.text = mi_text
    if let img = favoriteRecord.valueForKey("GalleryImage") {
      cell.galleryImage.image = UIImage(contentsOfFile: img.fileURL.path!)
    }

  }
  
  
  ///presentLocationServices: Sends an alert to the user to give the app location services
  func  presentLocationServicesAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert);
    let affirmitiveAction = UIAlertAction(title: "OK",  style: .Default) { (alertAction) -> Void in
      UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    alert.addAction(affirmitiveAction)
    presentViewController(alert, animated:true, completion: nil)

  }
  


  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last
    currentLocation = location!

  }
  
  ///refreshTable:  Refresh the data form cloudkit
  func refreshTable() {
    

    
    
    //only show an activity spinner for first load
    if (NSUserDefaults.standardUserDefaults().boolForKey("ActivityOneLaunch")) {
      startSpinner()
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ActivityOneLaunch")
      
    }
    //sync with cloudkit
    CloudKitManager.sharedInstance.sync { (results) -> Void in
     
      if let error = results[0] as? String  {
        if error == "error" {
          
          let alertController = UIAlertController(title: "No Internet Detected", message:
            "This app requires internet to view galleries", preferredStyle: UIAlertControllerStyle.Alert)
          alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
          
          self.presentViewController(alertController, animated: true, completion: nil)
          
          
        }
      }
      else {
      
        self.records = results as! [CKRecord]
        self.localRecords.removeAll()
        for rec in self.records {
          
          //store all the records within 100km
          if !self.localRecords.contains(rec){
   
            let meters = CLLocationDistance(self.currentLocation.distanceFromLocation((rec.objectForKey("Location") as? CLLocation)!))
            
              if meters < 100000 {
                self.localRecords.append(rec)
              }
          }
        }
        //if there are no local records check out the favorites
        if (self.localRecords.count == 0 ) {
          let alert = UIAlertController(title: "No Galleries Near You", message: "Please view all galleries or Favorites", preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
          self.stopSpinner()
          return
          }
      }
      self.stopSpinner()
      self.tableView.reloadData()
    }
    
  }
  



  //MARK: Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "galleryLocation" {
      
      if let detail = segue.destinationViewController as? GeoLocationViewController {
        if let selectedIssueCell = sender as? RecentTableViewCell {
        
          detail.record = selectedIssueCell.record
     
        }
        
      }
      
    }
    
  }
  
  ///startSpinner: Create a custom activity spinner view
  func startSpinner() {
    
    //create a container view so that the table cannot be moved
 
    container.frame = view.frame
    container.center = view.center
    container.backgroundColor = UIColor.clearColor()
    
    //create the box containing the spinner
    let loadingContainer: UIView = UIView()
    loadingContainer.frame = CGRectMake(0, 0, 150, 150)
    loadingContainer.center = CGPointMake(container.frame.size.width / 2, (container.frame.size.height / 2) - 100)
    loadingContainer.backgroundColor = UIColor.grayColor()
    loadingContainer.alpha = 0.3
    loadingContainer.clipsToBounds = true
    loadingContainer.layer.cornerRadius = 5
    
    
    //create the UIActivityIndicator
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    spinner.center = CGPointMake(loadingContainer.frame.size.width / 2, loadingContainer.frame.size.height / 2);
    let label = UILabel()
    label.frame = CGRectMake(0.0, 0.0, 120.0, 120.0)
    label.center = CGPointMake(loadingContainer.frame.size.width / 2, (loadingContainer.frame.size.height / 2) + 40.0);
    label.font = UIFont(name: "Futura", size: 13)
    label.text = "   Loading Nearby \n       Galleries"
    //add subviews
    label.numberOfLines = 0
    loadingContainer.addSubview(spinner)
    loadingContainer.addSubview(label)
    container.addSubview(loadingContainer)
    
    view.addSubview(container)
    spinner.startAnimating()
  
    
    //make the loading box small
    loadingContainer.transform = CGAffineTransformMakeScale(0.1, 0.1)
    
    //zoom it in
    UIView.animateWithDuration(0.2, animations: {
      loadingContainer.transform = CGAffineTransformMakeScale(1, 1)
    })
  }
  
  ///stopSpinner: get rid of the spinner
  func stopSpinner() {
    self.container.removeFromSuperview()
  }
  
  
  
  

}


