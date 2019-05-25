//
//  TutoriaViewController.swift
//  FastRoute
//
//  Created by apple on 8/19/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class UIPageViewControllerWithOverlayIndicator: UIPageViewController {
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews as! [UIView] {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubviewToFront(subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
}

class TutoriaViewController: UIViewController, UIPageViewControllerDataSource {

    private var pageViewController: UIPageViewControllerWithOverlayIndicator?

    private let contentImages = ["Default-iPhone-Portrait-750-Screen1",
                                 "Default-iPhone-Portrait-750-Screen2",
                                 "Default-iPhone-Portrait-750-Screen3"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DLog("TutoriaViewController.viewDidLoad")

        // Do any additional setup after loading the view.
        createPageViewController()
        setupPageControl()
        
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().statusBarHidden=true; // for status bar hide
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden=false; // for status bar hide
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // check for tutorial completion handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTutorialFinish:", name: Constants.NotificationKey.TutorialFinishedNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onTutorialFinish(notification: NSNotification) {
        if AppUtil.checkNetworkStatus(self) {
            if pageViewController != nil {
                pageViewController!.willMoveToParentViewController(nil)
                pageViewController!.view.removeFromSuperview()
                pageViewController!.removeFromParentViewController()
                
                let landingPageController = self.storyboard!.instantiateViewControllerWithIdentifier("LandingNavigationController") as! UINavigationController
                
                addChildViewController(landingPageController)
                self.view.addSubview(landingPageController.view)
                landingPageController.didMoveToParentViewController(self)
            }
        }
    }

    // MARK: View setup methods

    private func createPageViewController() {
        // get page controller from storyboard
        
        let pageController = UIPageViewControllerWithOverlayIndicator(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil);
        
        pageController.dataSource = self
        
        if contentImages.count > 0 {
            // initially the child page view controllers
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        
        // add page view controller to root view controller
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
//        appearance.backgroundColor = UIColor.whiteColor()
    }

    // MARK: Helper methods

    private func getItemController(itemIndex: Int) -> UIViewController? {
        
        if itemIndex < contentImages.count {
            let pageItemController = UIViewController()
            // grab custom screen

            let tutorialScreen = TutorialScreen()
            tutorialScreen.itemIndex = itemIndex
            tutorialScreen.imageName = contentImages[itemIndex]
            
            // update custom page control
            tutorialScreen.pageControl.numberOfPages = contentImages.count
            tutorialScreen.pageControl.currentPage = itemIndex
            
            pageItemController.view = tutorialScreen
//            view.backgroundColor = UIColor.greenColor()
            
            return pageItemController
        }
        
        return nil
    }
    
    
    // MARK: Data source methods

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemView = viewController.view as! TutorialScreen
        
        if itemView.itemIndex > 0 {
            return getItemController(itemView.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemView = viewController.view as! TutorialScreen
        
        if itemView.itemIndex+1 < contentImages.count {
            return getItemController(itemView.itemIndex+1)
        }
        
        return nil
    }
}
