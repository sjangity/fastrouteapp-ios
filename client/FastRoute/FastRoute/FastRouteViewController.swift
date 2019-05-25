//
//  FastRouteViewController.swift
//  FastRoute
//
//  Created by apple on 9/3/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import iAd
import AddressBook

class FastRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    var addressManager: AddressManager!
//    var fromLocation: FRLocation?
//    var waypoints: [FRWayPoint]?
    var bannerView: ADBannerView?
//    var wayPointsForTableView: Array<Array<FRWayPoint>>?
    var wayPointsForTableView: [[FRWayPoint]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate  = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // create ad banner
        createBanner()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Fast Route Summary";
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("dismissView:"))
        self.navigationItem.rightBarButtonItem = rightButton
        
//        if let waypoints = waypoints {
//            DLog("Showing waypoints:")
//
//            for waypoint : FRWayPoint in waypoints {
//                DLog(waypoint)
//            }
//        } else {
//            DLog("no waypoints found")
//        }

//        fromAddressLabel.backgroundColor = UIColor.clearColor()
//        fromAddressLabel.textColor = UIColor.grayColor()
//        fromAddressLabel.shadowColor = UIColor.clearColor()
//        fromAddressLabel.shadowOffset = CGSizeMake(0,1)
//        fromAddressLabel.font = UIFont.boldSystemFontOfSize(15)
//        AppUtil.updateCurrentLocationInUI(fromAddressLabel)

        initializeWayPointsForDisplay()

        styleButtons()
    }
    
    func styleButtons() {
        for aView in self.view.subviews as! [UIView] {
            var ct = aView.subviews.count
//            DLog("\(view.tag) - subviews: \(ct)")
            let filteredSubviews = aView.subviews.filter({$0.isKindOfClass(UIButton)}) as! [UIButton]
            for view in filteredSubviews {
                view.styled()
            }
        }
    }    
    
    func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func initializeWayPointsForDisplay() {
        DLog("FastRouteViewController.initializeWayPointsForDisplay")
        // need a 2-dimensional array to represent cols/rows in table view
//        wayPointsForTableView = Array<Array<FRWayPoint>>()
        wayPointsForTableView = [[FRWayPoint]]()
    
        var totalDistance = 0
        var totalDuration = 0
    
        if let waypoints = addressManager?.fastRoute {
            for waypoint : FRWayPoint in waypoints {
//                DLog("Waypoint Duration: \(waypoint.duration)")
                totalDuration += waypoint.duration
                totalDistance += waypoint.distance
                var newarray = [waypoint] // turn into array
                wayPointsForTableView?.append(newarray)
            }
        }
        
        // distance conversion
        var distanceString = ""
        var conversion = Double(totalDistance)/1609.34
        if conversion < 0.5 {
            conversion = Double(totalDistance) * 3.28084
            var int_conversion = Int(round(conversion))
            distanceString = "\(int_conversion) feet"
        } else {
            let divisor = pow(10.0, Double(2))
            let rounded = round(conversion * divisor) / divisor
            distanceString = "\(rounded) miles"
        }
        self.totalDistance.text = distanceString
        self.totalDuration.text = "\(totalDuration/60) minutes"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // MARK: show route page view controller
    @IBAction func letsGoButtonPressed(sender: AnyObject) {
    
        var routeDetailsVC = RouteDetailsViewController()
        routeDetailsVC.waypoints = addressManager?.fastRoute
    
        var navigationController = UINavigationController(rootViewController: routeDetailsVC)
        
//        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("dismissView:"))
//        navigationController.navigationItem.rightBarButtonItem = rightButton
        
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
//    func dismissView(sender: AnyObject) {
////        dismissViewControllerAnimated(true, completion: nil)
//        DLog("dismiss")
//    }
    

    // MARK: Table View Delegate/Data sources
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        var cell = tableView.dequeueReusableCellWithIdentifier("kRouteListTableView") as? AddressListTableViewCell
        
        if cell == nil {
            cell = AddressListTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "kRouteListTableView")
        }
        
        var section = indexPath.section
        var row = indexPath.row
//        var waypoint = wayPointsForTableView[section][row] as FRWayPoint
//        DLog(waypoint)
        
        if let waypoint = wayPointsForTableView?[section][row] {
//            DLog(waypoint)
//            cell.textLabel?.text = waypoint.endAddress.addressText
            var parsedLocation = AppUtil.parseAddress(waypoint.endAddress.addressText!)
            if let street = parsedLocation["Street"] as? String {
                var ZIP = parsedLocation[kABPersonAddressZIPKey] as? String
                var city = parsedLocation[kABPersonAddressCityKey] as? String
                var state = parsedLocation[kABPersonAddressStateKey] as? String
                cell?.addressPrimary.text = street
                cell?.addressSecondary.text = "\(city!), \(state!) \(ZIP!)"
                if let distance = waypoint.distanceInMiles {
                    cell?.addressDistance.text = "\(distance)"
                } else {
                    cell?.addressDistance.text = "0 miles"
                }
            }
        }
            
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30.0
//    }
    
//    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let count = wayPointsForTableView?.count {
            return count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let count = addressManager?.fastRoute?.count {
            return "Route \(section+1) of \(count)"
        }
        return "Empty"
    }
    
    // MARK: Banner
    
    func createBanner() {
    
        self.canDisplayBannerAds = true
    
//        bannerView = ADBannerView(adType: .Banner)
        if let bannerView = bannerView {
            bannerView.setTranslatesAutoresizingMaskIntoConstraints(false)
            bannerView.delegate = self
            view.addSubview(bannerView)
            
            // banner constraints - full-width and anchored at bottom of page
            let viewsDictionary = ["bannerView": bannerView]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
            //        bannerView.center = CGPoint(x: bannerView.center.x, y: view.bounds.size.height - bannerView.frame.size.height / 2)
            //        DLog("center: \(bannerView.center)")
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        DLog("success")
        bannerView?.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        DLog("failed to load ad")
        bannerView?.hidden = true
    }
}
