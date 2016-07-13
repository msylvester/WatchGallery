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
import CoreData
import WebKit

///SearchTableViewController: Manage views associated with all galleries

class SearchTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  //MARK: Properties
  var currentPredicate: NSPredicate?
  let container = UIView()
  let searchController = UISearchController(searchResultsController: nil)
  let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
  var filteredRecords = [CKRecord]()
  var records = [CKRecord]()

  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.searchBarStyle = .Prominent
    searchController.searchBar.delegate = self
    tableView.tableHeaderView = searchController.searchBar
    definesPresentationContext = true
    searchController.searchBar.barStyle = UIBarStyle.Black
    

  }
  
  

  
  ///refreshTable:  helper fucnction to get data form cloudkti
  func refreshTable() {
  
    //only show the activty indicators on first load
    if (NSUserDefaults.standardUserDefaults().boolForKey("ActivityTwoLaunch")) {
      startSpinner()
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "ActivityTwoLaunch")
      
    }
    
    CloudKitManager.sharedInstance.sync { (results) -> Void in
      
      if let error = results[0] as? String  {
        if error == "error" {
          
          let alertController = UIAlertController(title: "No Internet Detected", message:
            "This app requires internet to view galleries", preferredStyle: UIAlertControllerStyle.Alert)
          alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
          
          self.presentViewController(alertController, animated: true, completion: nil)
   
          
        }
      }
      
      self.records = results as! [CKRecord]
      
      self.tableView.reloadData()
        self.stopSpinner()
    }
  
  }
  
  override func viewWillAppear(animated: Bool) {

    self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
    refreshTable()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
   
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if searchController.active && searchController.searchBar.text != "" {
      return filteredRecords.count
    }
    
    return records.count
  
  }


  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    

    let cell = tableView.dequeueReusableCellWithIdentifier("AllCell", forIndexPath: indexPath) as? AllGalleriesTableViewCell
    self.configureCell(cell!, atIndexPath: indexPath)
    return cell!
  }
  
  
  ///configureCell: Helper function to set the properties of a cell 
  ///-parameters: cell object for this table view and the row
  func configureCell(cell: AllGalleriesTableViewCell, atIndexPath indexPath: NSIndexPath) {
    
    let favoriteRecord = records[indexPath.row]
    if searchController.active && searchController.searchBar.text != "" {
      let filteredRecord = filteredRecords[indexPath.row]
      cell.record = filteredRecord
      cell.allGalleriesLabel.text = filteredRecord.objectForKey("NameOFGallery") as? String
      if let img = filteredRecord.valueForKey("GalleryImage") {
        cell.allGalleryImage.image = UIImage(contentsOfFile: img.fileURL.path!)
      }
    }
    else{
      cell.record = favoriteRecord
      cell.allGalleriesLabel.text = favoriteRecord.objectForKey("NameOFGallery") as? String
        if let img = favoriteRecord.valueForKey("GalleryImage") {
            cell.allGalleryImage.image = UIImage(contentsOfFile: img.fileURL.path!)
      }
    }
    
  }
  

  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "allShowCL" {
      if let detail = segue.destinationViewController as? ExhibitViewController {
        if let selectedIssueCell = sender as? AllGalleriesTableViewCell {
          detail.record = selectedIssueCell.record
     
        }
      }
    }
  }
  
  
  
  ///stopSpinner:  Closes custom activty indicator view
  func stopSpinner() {
    self.container.removeFromSuperview()
  }
  
  ///startSpinnner:  Create a custom view to display while cloudkit data is loading
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
    label.text = "     Loading All \n       Galleries"
    
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
  

  func filterContentForSearchText(searchText: String, scope: String = "All") {
    filteredRecords = records.filter { record in
      print(searchText.lowercaseString)
      //rint(record.objectForKey("NameOFGallery") as? String)
    let trimmedString = (record.objectForKey("NameOFGallery") as? String)!.removeWhitespace()
      print("now printing trimmed string")
      print(trimmedString)
      
      return trimmedString.localizedStandardContainsString(searchText)
    }
    
    tableView.reloadData()
  }
  
}

//Extensions
extension SearchTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}


extension SearchTableViewController: UISearchBarDelegate {
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    //filterResultsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
  }
}

//extend String fucntionality to support for removing white space
extension String {
  func replace(string:String, replacement:String) -> String {
    return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
  }
  
  func removeWhitespace() -> String {
    return self.replace(" ", replacement: "")
  }
}
