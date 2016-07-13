//
//  InstructionViewController.swift
//  WatchGallery
//
//  Created by Michael on 5/1/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit

///-Attributions: https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/
class InstructionViewController: UIViewController {
  
  //MARK: Properties
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var containerView: UIView!
  
  var instructionPageViewController: InstructionPageViewController? {
    didSet {
      instructionPageViewController?.tutorialDelegate = self
    }
  }
  
  override func viewWillAppear(animated: Bool) {

    let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
    if firstLaunch  {
    
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let viewController = storyboard.instantiateInitialViewController() as! UITabBarController
      self.view.window?.rootViewController = viewController
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLaunch")
      
      return
    }
    else {

      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pageControl.addTarget(self, action: #selector(InstructionViewController.didChangePageControlValue), forControlEvents: .ValueChanged)
  }
 
  
  
  ///didChangePageControlValue:  Change the page
  func didChangePageControlValue() {
    instructionPageViewController?.scrollToViewController(index: pageControl.currentPage)
  }
  
  //MARK: Actions
  ///didTapNextButton:  If user tapped "go to app" button then dismiss this view
  @IBAction func didTapNextButton(sender: UIButton) {
   
    // Load the initial view controller from `Main.storyboard`
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = storyboard.instantiateInitialViewController() as! UITabBarController
    self.view.window?.rootViewController = viewController
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLaunch")
    
    return
      // Animate between the view controller's views and then swap the root view
      // controllers when donw
      UIView.transitionFromView(self.view,
                                toView: viewController.view, duration: 0.5,
                                options: UIViewAnimationOptions.TransitionFlipFromLeft) { (completed) -> Void in
                                  if (completed) {
                                    self.view.window?.rootViewController = viewController
                                  }
    }
    
    
    
  }
  ///MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let instructionPageViewController = segue.destinationViewController as? InstructionPageViewController {
      self.instructionPageViewController = instructionPageViewController
    }
  }
  
  

}



extension InstructionViewController: InstructionPageViewControllerDelegate {
  
  func instructionPageViewController(instructionPageViewController: InstructionPageViewController,
                                  didUpdatePageCount count: Int) {
    pageControl.numberOfPages = count
  }
  
  func instructionPageViewController(instructionPageViewController: InstructionPageViewController,
                                  didUpdatePageIndex index: Int) {
    pageControl.currentPage = index
  }
  
}
