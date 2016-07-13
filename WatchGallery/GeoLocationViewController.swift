//
//  GeoLocationViewController.swift
//  WatchGallery
//
//  Created by Michael on 4/28/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CloudKit
import DataKit
import SafariServices

class GeoLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
  //MARK: Properties
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var galleryName: UILabel!
  @IBOutlet weak var mapKit: MKMapView!
  @IBOutlet weak var hoursLabel: UILabel!
 
  let locationManager = CLLocationManager() // Add this statement
  var currentLocation = CLLocation()
  var recImage = UIImage()
  var recArtist = ""
  var recDescription = ""
  var recExhibit = ""
  var recWebsite = ""
  var recAddress = ""
  var recDesitionation = CLLocation()
  var previousLocation = CLLocation()
  var recGallery = ""
  let container = UIView()
  var recHours = ""
  var recExhibitImage = UIImage()
  var recExhibitImageTwo = UIImage()
  
 
  weak var record: CKRecord?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    //Don't show the buttons for directions and favorites immediately
    let delta: Int64 = 1 * Int64(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, delta)
    dispatch_after(time, dispatch_get_main_queue(), {
      
      self.view.viewWithTag(114)?.hidden = false
      self.view.viewWithTag(113)?.hidden = false
      self.view.viewWithTag(112)?.hidden = false
  
    });
   
  
  }
  @IBOutlet weak var openSafari: UIButton!

  ///openSite:  Go to Art Gallery Page in app
  @IBAction func openSite(sender: AnyObject) {
    
      let svc = SFSafariViewController(URL: NSURL(string: recWebsite)!)
      self.presentViewController(svc, animated: true, completion: nil)
  
  }

  
  override func viewWillAppear(animated: Bool) {

    self.locationManager.delegate = self
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.startUpdatingLocation()
    self.mapKit.showsUserLocation = true
    showAllPoints()
    
    
    if let name = record?.objectForKey("NameOFGallery") as? String  {
        galleryName.text = name
    }

    if let name = record?.objectForKey("GalleryAddress") as? String  {
        addressLabel.text = name
    }
    
    if let destination = record?.objectForKey("Location") as? CLLocation{
        recDesitionation = destination
    }
    
    if let img = record?.valueForKey("GalleryImage") as? CKAsset {
        recImage = UIImage(contentsOfFile: img.fileURL.path!)!
    }
    
    if let website = record?.valueForKey("Website") as? String {
        recWebsite =  website
    }
    
    if let artist  = record?.valueForKey("Artist") as? String {
        recArtist = artist
      
    }
    
    if let description = record?.valueForKey("Description") as? String {
        recDescription = description

    }
    
    if  let currentExhibit = record?.valueForKey("CurrentExhibit") as? String {
        recExhibit = currentExhibit
    }
    
    if let gallery = record?.valueForKey("NameOFGallery") as? String {
      
        recGallery = gallery
    }
    
 
    if let hours = record?.valueForKey("OpenTimes") as? String {
        hoursLabel.text = hours
    }
    
    if let address = record?.valueForKey("GalleryAddress") as? String {
        recAddress = address
    }
    
    if let img = record?.valueForKey("ImageUrlOne"), let img2 = record?.valueForKey("ImageUrlTwo") {
        recExhibitImage = UIImage(contentsOfFile: img.fileURL.path!)!
        recExhibitImageTwo = UIImage(contentsOfFile: img2.fileURL.path!)!
      
    }
    
  }

  
  @IBAction func tapForDirections(sender: AnyObject) {
    
    startSpinner()
    
    // Create request and set properties
    let request = MKDirectionsRequest()

    request.source = MKMapItem(placemark: MKPlacemark(coordinate:
     CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), addressDictionary: nil))
    
    // Destination location
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate:
      CLLocationCoordinate2D(latitude: recDesitionation.coordinate.latitude, longitude: recDesitionation .coordinate.longitude), addressDictionary: nil))
    
    // Specify the route type
    request.requestsAlternateRoutes = true
    request.transportType = .Automobile
    
    // Request directions
    let directions = MKDirections(request: request)
    directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
      guard let unwrappedResponse = response else { return }
      

      var directions = ""
      var number = 1
      for step in (unwrappedResponse.routes.first?.steps)! as [MKRouteStep] {
    
        directions += String(number) + "." + " " +  step.instructions + "\n"
        number += 1 
        
        
      }
      
      //Send directions to next next view
      let next = self.storyboard?.instantiateViewControllerWithIdentifier("Directions") as! DirectionsViewController
      
      next.directions = "DIRECTIONS TO: \(self.recGallery) \n \n" + directions
      
      self.stopSpinner()
      self.presentViewController(next, animated: false, completion: nil)
      
    }
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
    
  }
    

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   let location = locations.last
    currentLocation = location!
    let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    
     let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.130, longitudeDelta: 1.3))
    

    self.mapKit.setRegion(region, animated: true)
  }

  ///tapFavorites:  Save favorites to app group defaults
  @IBAction func tapFavorites(sender: AnyObject) {
      startSpinner()
      let sharedItem: NSDictionary = [ "Artist": recArtist,
                                       "CurrentExhibit": recExhibit,
                                       "DescriptionOfExhibit": recDescription,
                                       
                                       "imageData": ((UIImagePNGRepresentation(recImage)))!,
                                       "ExhibitImageOne": ((UIImagePNGRepresentation(recExhibitImage)))!,
                                       "ExhibitImageTwo": ((UIImagePNGRepresentation(recExhibitImageTwo)))!,
                                       "NameOFGallery": recGallery,
                                       "Website": recWebsite,
                                       "Address": recAddress,
                                       "Hours": recHours
      
      ]
    
      LocalDefaultsManager.sharedInstance.add(object: sharedItem)
      stopSpinner()
    }
    

  ///showAllPoints: Show the nearest Gallery on the map and annotate it
  func showAllPoints() {

    if let name = record?.objectForKey("NameOFGallery") as? String, let address = record?.objectForKey("GalleryAddress") as? String, location = record?.objectForKey("Location") as? CLLocation {
      
              let coordinate1: CLLocationCoordinate2D = location.coordinate

        let annotation = MapAnnotation(title: name, subtitle: address, coordinate: coordinate1)

        mapKit.showAnnotations([annotation], animated: true)
    }



  }


  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
  
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if let annotation = annotation as? MapAnnotation {
      let identifier = "CustomPin"
      
      // Create a new view
      var view: MKPinAnnotationView
      
      // Deque an annotation view or create a new one
      if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
        dequeuedView.annotation = annotation
        view = dequeuedView
      } else {
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
       
      }
      return view
    }
    return nil
}
 
  
  func startSpinner() {
    
    //create a container view so that the table cannot be moved
    //  container = UIView()
    container.frame = view.frame
    container.center = view.center
    container.backgroundColor = UIColor.clearColor()
    
    //create the box containing the spinner
    let loadingContainer: UIView = UIView()
    loadingContainer.frame = CGRectMake(0, 0, 150, 150)
    loadingContainer.center = CGPointMake(container.frame.size.width / 2, (container.frame.size.height / 2) - 100)
    loadingContainer.backgroundColor = UIColor.grayColor()
    loadingContainer.alpha = 0.6
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
    label.text = "   Fetching Directions  "
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
  
  //get rid of the spinner
  func stopSpinner() {
    self.container.removeFromSuperview()
  }
  
  
  
  //MARK:  Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showExhibit" {
      if let detail = segue.destinationViewController as? ExhibitViewController {
        detail.record = record
        }
    }
  }

}