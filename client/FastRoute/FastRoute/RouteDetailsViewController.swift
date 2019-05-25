//
//  RouteDetailsViewController.swift
//  FastRoute
//
//  Created by apple on 9/3/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class RouteDetailsViewController: UIViewController, UIPageViewControllerDataSource, RouteSubDetailsViewControllerDelegate {

    var waypoints: [FRWayPoint]?
    var pageTitles: [String]!
    var routePageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        DLog("RouteDetailsViewController.viewDidLoad")
        
        setupPageViewControllers()
        
        self.navigationItem.title = "Route Details"
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("dismissView:"))
        self.navigationItem.rightBarButtonItem = rightButton
//        self.navigationController?.navigationItem.rightBarButtonItem = rightButton
        
    }
    
    func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setupPageViewControllers() {
//        routePageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("routePageViewController") as! UIPageViewController

//        pageTitles = ["Route 1 of 2", "Route 2 of 2"]
        pageTitles = generatePageTitles()

        routePageViewController = UIPageViewController()
        routePageViewController.dataSource = self
        routePageViewController.navigationItem.leftBarButtonItem?.title = "test"
        if let startingVC = viewControllerAtIndex(0) {
            var viewControllers = [startingVC]
            routePageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            routePageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

//            var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("dismissView:"))
//            routePageViewController.navigationController?.navigationItem.rightBarButtonItem = rightButton
            
            addChildViewController(routePageViewController)
            view.addSubview(routePageViewController.view)
            routePageViewController.didMoveToParentViewController(self)
        }
    }
    
    func generatePageTitles() -> [String] {
        var response = [String]()
        var total = waypoints?.count
        var count=1
        for waypoint : FRWayPoint in waypoints! {
            var title = "Route \(count) of \(total!)"
            count+=1
            response.append(title)
        }
        return response
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Page view controller helper
    func changePage(direction: UIPageViewControllerNavigationDirection, fromIndex: Int) {
        
        var index = fromIndex
        
        if (direction == UIPageViewControllerNavigationDirection.Forward) {
            index += 1
        } else {
            index -= 1
        }

        if let startingVC = viewControllerAtIndex(index) {
            var viewControllers = [startingVC]
            routePageViewController.setViewControllers(viewControllers, direction: direction, animated: false, completion: nil)
        }
    }
    
    func previousPageRequested(fromIndex: Int) {
//        DLog("previous page requested in delegate")
        changePage(UIPageViewControllerNavigationDirection.Reverse, fromIndex: fromIndex)
    }
    
    func nextPageRequested(fromIndex: Int) {
//        DLog("next page requested in delegate")
        
        changePage(UIPageViewControllerNavigationDirection.Forward, fromIndex: fromIndex)
    
    }
    
    func viewControllerAtIndex(index: Int) -> RouteSubDetailsViewController? {
    
        if (self.pageTitles.count == 0) || (index >= self.pageTitles.count) {
            return nil
        }
        
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        if let routeVC = storyboard.instantiateViewControllerWithIdentifier("routeSubDetailsView") as? RouteSubDetailsViewController {

            routeVC.waypoint = waypoints?[index]
            routeVC.pageText = pageTitles[index]
            routeVC.delegate = self
            routeVC.pageIndex=index
            routeVC.pageTotal=waypoints?.count
//            routeVC.wayPointText.text = pageTitles[index]
            
            return routeVC
        }
        
        return nil
    }
    
    // MARK: Page view controller data source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        var index = (viewController as! RouteSubDetailsViewController).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
    
        index = index - 1;
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        var index = (viewController as! RouteSubDetailsViewController).pageIndex
        
        if (index == NSNotFound) {
            return nil;
        }
        
        index = index + 1;
        if (index == self.pageTitles.count) {
            return nil;
        }
        return viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
