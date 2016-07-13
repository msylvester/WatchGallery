//
//  DirectionsViewController.swift
//  WatchGallery
//
//  Created by Michael on 4/29/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit

///DirectionsViewController: holds the view containging directions to an Art Gallery


class DirectionsViewController: UIViewController {

  //MARK: Properties
  @IBOutlet weak var directionsTwo: UITextView!
  var directions = ""
  
  override func viewDidLoad() {
      super.viewDidLoad()
      directionsTwo.text = directions
      // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  ///MARK: Actions
  
  ///tapDismiss:  Dismiss the viewcontroller
  ///-parameteres: UIButton
  ///-complexity: O(1)
  
  @IBAction func tapDismiss(sender: AnyObject) {
    
    self.dismissViewControllerAnimated(false, completion: nil)  
    
  }

}
