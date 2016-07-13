//
//  InstructionPageViewController.swift
//  WatchGallery
//
//  Created by Michael on 5/1/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit

///-Attributions: https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/
  class InstructionPageViewController: UIPageViewController {
    
    
    //MARK: Properties
    weak var tutorialDelegate: InstructionPageViewControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
     
      return [self.newColoredViewController("Green"),
              self.newColoredViewController("Red")]
    }()
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      dataSource = self
      delegate = self
      
      if let initialViewController = orderedViewControllers.first {
        scrollToViewController(initialViewController)
      }
      
      tutorialDelegate?.instructionPageViewController(self,
                                                   didUpdatePageCount: orderedViewControllers.count)
    }
    
    ///sctollToNextViewControlle:  Scroll to next view
    func scrollToNextViewController() {
      if let visibleViewController = viewControllers?.first,
        let nextViewController = pageViewController(self,
                                                    viewControllerAfterViewController: visibleViewController) {
        scrollToViewController(nextViewController)
      }
    }
    
    ///scrollToViewController: Account for negative direction
    func scrollToViewController(index newIndex: Int) {
      if let firstViewController = viewControllers?.first,
        let currentIndex = orderedViewControllers.indexOf(firstViewController) {
        let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .Forward : .Reverse
        let nextViewController = orderedViewControllers[newIndex]
        scrollToViewController(nextViewController, direction: direction)
      }
    }
    
    private func newColoredViewController(color: String) -> UIViewController {
      return UIStoryboard(name: "instructions", bundle: nil) .
        instantiateViewControllerWithIdentifier("\(color)ViewController")
    }
    
    
     ///scrollToViewController: Scrolls to the given 'viewController' page.
     ///-parameter viewController: the view controller to show.
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .Forward) {
      setViewControllers([viewController],
                         direction: direction,
                         animated: true,
                         completion: { (finished) -> Void in
                          // Setting the view controller programmatically does not fire
                          // any delegate methods, so we have to manually notify the
                          // 'tutorialDelegate' of the new index.
                          self.notifyInstructionDelegateOfNewIndex()
      })
    }
    
  
    
    private func notifyInstructionDelegateOfNewIndex() {
      if let firstViewController = viewControllers?.first,
        let index = orderedViewControllers.indexOf(firstViewController) {
        tutorialDelegate?.instructionPageViewController(self,
                                                     didUpdatePageIndex: index)
      }
    }
    
  }
  
  // MARK: UIPageViewControllerDataSource
  
  extension InstructionPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
      guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
        return nil
      }
      
      let previousIndex = viewControllerIndex - 1
      
      // User is on the first view controller and swiped left to loop to
      // the last view controller.
      guard previousIndex >= 0 else {
        return orderedViewControllers.last
      }
      
      guard orderedViewControllers.count > previousIndex else {
        return nil
      }
      
      return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
      guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
        return nil
      }
      
      let nextIndex = viewControllerIndex + 1
      let orderedViewControllersCount = orderedViewControllers.count
      
      // User is on the last view controller and swiped right to loop to
      // the first view controller.
      guard orderedViewControllersCount != nextIndex else {
        return orderedViewControllers.first
      }
      
      guard orderedViewControllersCount > nextIndex else {
        return nil
      }
      
      return orderedViewControllers[nextIndex]
    }
    
  }
  
  extension InstructionPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                                               previousViewControllers: [UIViewController],
                                               transitionCompleted completed: Bool) {
      notifyInstructionDelegateOfNewIndex()
    }
    
  }
  
  protocol InstructionPageViewControllerDelegate: class {
    
  
    func instructionPageViewController(instructionPageViewController: InstructionPageViewController,
                                    didUpdatePageCount count: Int)
    
    
    func instructionPageViewController(instructionPageViewController: InstructionPageViewController,
                                    didUpdatePageIndex index: Int)
    
  }



