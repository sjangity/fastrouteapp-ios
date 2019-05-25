//
//  LandingViewController.swift
//  FastRoute
//
//  Created by apple on 8/20/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import iAd
import CoreLocation
import AddressBook

class LandingViewController: UIViewController, ADBannerViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, NewAddressViewDelegate, AddressManagerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var userLocationImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromAddressLabel: UILabel!

    var bannerView: ADBannerView?
    var locationManager: CLLocationManager?
    var locationUpdateOn: Bool?
    var geocoder: CLGeocoder?
    var geoTimer: NSTimer?

    var locationTimer: NSTimer?
    
    var addressManager:AddressManager?
    var popViewController : NewAddressViewController!
    
    // MARK: Lifecycle
    
/*
awakeFromNib
viewDidLoad
viewWillAppear
viewWillLayoutSubviews
viewDidLayoutSubviews
viewDidAppear
*/
    
    override func viewWillAppear(animated: Bool) {
        DLog("LandingViewController.viewWillAppear")
//        self.navigationItem.title = "Route Test"
//        var custombutton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
//        custombutton.setImage(UIImage(named: "setting-gear.png"), forState: UIControlState.Normal)
//        custombutton.setTitle("Settings", forState: UIControlState.Normal)
//        custombutton.sizeToFit()
//        var customBarButtonItem = UIBarButtonItem(customView: custombutton)
//        self.navigationItem.leftBarButtonItem = customBarButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DLog("LandingViewController.viewDidLoad")
        
        // get users location
        getUsersLocation()
        
        // by registering for cell class here, our table view's dequeue will auto vend instances as needed
//        tableView.registerClass(AddressListTableViewCell.self, forCellReuseIdentifier: "kAddressListTableView")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // create ad banner
        createBanner()        
        
//        addressManager = AddressManager()
        addressManager = AddressManager.getSharedManager()
//        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        addressManager = delegate.addressManager
        
        // TODO: remove in production code - only for testing
//        addressManager = AddressManager.loadAddressManagerFromDiskTestPath("AddressManagerData")
//        addressManager?.printData()
        addressManager?.delegate = self

        styleButtons()
        
//        fromAddressLabel.text = "865 Hollenbeck Ave., Sunnyvale, CA 94087"
        fromAddressLabel.backgroundColor = UIColor.clearColor()
        fromAddressLabel.textColor = UIColor.grayColor()
        fromAddressLabel.shadowColor = UIColor.clearColor()
        fromAddressLabel.shadowOffset = CGSizeMake(0,1)
//        fromAddressLabel.font = UIFont.boldSystemFontOfSize(15)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onFetchReverseGeocode:", name: Constants.NotificationKey.AddressReverseGeocodingNotification, object: nil)
        
        AppUtil.updateCurrentLocationInUI(fromAddressLabel)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        geoTimer = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        DLog("LandingViewController.viewDidAppear")
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
    
    // MARK: UI Action Handlers
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let fastRouteViewController = segue.destinationViewController as? FastRouteViewController {
//            // pass address manager instance to child
//            fastRouteViewController.addressManager = addressManager
//        
////            fastRouteViewController.addressArray = addressManager?.addressArray
////            if let currentLocation = AppUtil().loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
////                fastRouteViewController.fromLocation = currentLocation
////                fastRouteViewController.waypoints = addressManager?.fastRoute
////            }
//        }
//    }
    
    @IBAction func newRouteButtonPressed(sender: AnyObject) {
        
        AddressManager.deleteAddressManagerOnDisk()
        
        // grab refernece to new address manager
        addressManager = nil
        addressManager = AddressManager()
        addressManager?.delegate = self
        
        tableView.reloadData()
    }
    
    // MARK: Address manager delegate
    func waypointsDataResponse(status: Bool) {
        DLog("LandingViewController.waypointsdata delegate message")
        
        if status {
            // track changes after directions so we can prevent multiple GMS directions API requests if the address data hasn't changed
            addressManager?.hasChanged = false
        
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            var fastRouteViewController = storyboard?.instantiateViewControllerWithIdentifier("FastRouteViewController") as! FastRouteViewController
    
            fastRouteViewController.addressManager = addressManager
            
            var navigationController = UINavigationController(rootViewController: fastRouteViewController)
            navigationController.modalTransitionStyle=UIModalTransitionStyle.FlipHorizontal
            presentViewController(navigationController, animated: true, completion: nil)
        } else {
            DLog("show error that directions could not be fetched")
        }
    }
    
    @IBAction func findFastRouteButtonPressed(sender: AnyObject) {
    
        if AppUtil.checkNetworkStatus(self) {
    
            // do error validation on address input
            var alertTitle: String?
            var alertMessage: String?
            
            if addressManager?.addressArray.count < 2 {
                alertTitle = "Route Error"
                alertMessage = "Please enter 2 or more addresses to get Fast Route Results. Click on ADD NEW DESTINATION."
            }
            
            if alertMessage != nil {
                let alert = UIAlertController(title: alertTitle!, message: alertMessage!, preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) in
    //                DLog("You pressed a button")
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
            } else {

                if addressManager?.hasChanged == true {

                        // if no errors do network request
                        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        hud.labelText = "Searching..."
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0),{
                    
                            if let currentLocation = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
                                
                                if let addresses = self.addressManager?.addressArray {
                                    // network request to download 'Directions JSON'
                                    self.addressManager?.bestRoute(currentLocation: currentLocation, nodeLocations: addresses)
                                }
                            }
                        })
                
                } else {
    //                DLog("showing cached google results data")
                    waypointsDataResponse(true)
                }
            
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: New address Delegate
   func listSubviewsOfView(view: UIView) {
        var subviews = self.view.subviews
        if subviews.count == 0 {
            return
        }
        for view in subviews {
            DLog(view.description)
        }
    }
    
    func newAddressAdded(location: FRLocation) {
        DLog("newAddressAdded: delegate called")

        popViewController.removeAnimate()
        
        // update address array
        // add new location to address manager
        addressManager?.addAddress(location)
        addressManager?.saveAddressManagerToDisk()
        
        // update table view
        updateAddressTableView()
    }
    
    func updateAddressTableView() {
        DLog("updateAddressTableView")

        if let count = addressManager?.addressArray.count {
            var newIndexPath = NSIndexPath(forRow: count - 1, inSection: 0)

            var indexPathArray = [AnyObject]()
            indexPathArray.append(newIndexPath)
            
            var cc = tableView.numberOfRowsInSection(0)
    //        DLog("number of rows in data: \(addressManager.addressArray.count)")
    //        DLog("number of rows in section 0: \(cc)")
    //        DLog("inserting into index path: \(indexPathArray)")
            
            self.tableView.insertRowsAtIndexPaths(indexPathArray, withRowAnimation: UITableViewRowAnimation.None)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addAdressButtonPressed(sender: AnyObject) {
        if AppUtil.checkNetworkStatus(self) {
    //        DLog("addAdressButtonPressed pressed")
            
            popViewController = NewAddressViewController(nibName: "NewAddressViewController", bundle: nil)
            popViewController.delegate = self
            popViewController.addressManager = addressManager
            popViewController.showInView(self.view)
        }
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        DLog("tableView.numberOfRowsInSection")
        if let count = addressManager?.addressArray.count {
            return count
        }
//        DLog("count = \(count)")
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCellWithIdentifier("kAddressListTableView") as? AddressListTableViewCell
        
        if cell == nil {
            cell = AddressListTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "kAddressListTableView")
        }
        
        if let location = addressManager?.addressArray[indexPath.row] {
            var parsedLocation = AppUtil.parseAddress(location.addressText!)
            if let street = parsedLocation["Street"] as? String {
                var ZIP = parsedLocation[kABPersonAddressZIPKey] as? String
                var city = parsedLocation[kABPersonAddressCityKey] as? String
                var state = parsedLocation[kABPersonAddressStateKey] as? String
                cell?.addressPrimary.text = street
                cell?.addressSecondary.text = "\(city!), \(state!) \(ZIP!)"
//                if let distance = location.distanceInMiles {
//                    cell?.addressDistance.text = "\(distance)"
//                } else {
//                    cell?.addressDistance.text = "0 miles"
//                }
            }
        }

        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TO DESTINATION(s)"
    }
    
    // MARK: Banner and Delegate
    
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
    
//    func createBannerTmp() {
//        DLog("LandingViewController.createBanner")
////        self.canDisplayBannerAds = true
//        bannerView = ADBannerView(frame: CGRectMake(0, self.view.frame.size.height-50, 320, 50))
//        bannerView?.delegate = self
//            DLog("Loading banner")
//            if (bannerView?.superview == nil) {
//                self.view.addSubview(bannerView!)
//            }
//            
//            let viewsDictionary = ["bannerView": bannerView as! AnyObject]
//            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDictionary))
//            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bannerView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDictionary))
//
//            bannerView?.hidden = false
//    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        DLog("LandingViewController.bannerViewDidLoadAd")
        bannerView?.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        DLog("failed to load ad")
        bannerView?.hidden = true
    }
    
    // MARK: Location
    
    func onFetchReverseGeocode(notification: NSNotification) {
        DLog("Reverse Geocoding complete")
        
    }
    
    func getUsersLocation() {
        if AppUtil.checkNetworkStatus(self) {
            if let location = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
            
                DLog("location found from defaults: \(location)")
            
            } else {
                DLog("location not found, prompt for user location")
                
                if (locationTimer != nil ) {
                    DLog("getting new location timer")
                    locationManager?.stopUpdatingLocation()
                    locationTimer?.invalidate()
                    locationTimer = nil
                }
                
                locationTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "grabLocationIfPossible", userInfo: nil, repeats: false)
            }
        }
    }
    
    func grabLocationIfPossible() {
        DLog("Grab location if possible")
        locationUpdateOn = true
        
        if locationUpdateOn != nil {
            var locationEnabled = CLLocationManager.locationServicesEnabled()
            if !locationEnabled {
                // show location not found error
                locationUpdateOn = false
                DLog("location not found, prompt for user location")
            } else {
                if locationManager == nil {
                    locationManager = CLLocationManager()
                    locationManager?.delegate = self
                    locationManager?.desiredAccuracy=kCLLocationAccuracyBest
                    if locationManager?.respondsToSelector("requestWhenInUseAuthorization") != nil {
                        locationManager?.requestWhenInUseAuthorization()
                    }
                    if locationManager?.respondsToSelector("requestAlwaysAuthorization") != nil {
                        locationManager?.requestAlwaysAuthorization()
                    }
                    locationManager?.distanceFilter=kCLDistanceFilterNone
                } else {
                    DLog("using existing location manager")
                }
                DLog("start updating user location")
                
                locationManager?.startUpdatingLocation()
            }
        } else {
            DLog("stop updating user location")
            
            locationManager?.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        DLog("locationManager.didFailWithError")
        if error.code == CLError.Denied.rawValue {
            locationUpdateOn = false

//            view alert = UIAlertView(title: "test alert", message: "yes this is an alert", delegate: self, cancelButtonTitle: <#String?#>)
//            view alert = UIAlertView(title: "Please enable location to use this app.", message: "yes this is an alert", delegate: self, cancelButtonTitle: "Settings", otherButtonTitles: nil, ...)
//            presentationController(aler
            let alertVC = UIAlertController(title: "Location Required", message: "Fast Route requires location services to operate. Please enable location services in Settings to use the app.", preferredStyle: UIAlertControllerStyle.Alert)
            alertVC.addAction(UIAlertAction(title: "Go to settings", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
                //go to settings
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))

            presentViewController(alertVC, animated: true, completion: nil)
        } else {
            DLog("Code: \(error.code), description: \(error.localizedDescription)")
//            let alertMessage = error.localizedDescription
            let alertMessage = "Error getting your location."
            let alertTitle = "Location Error"
            let alertVC = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertVC.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
            
//                self.locationTimer?.invalidate()
//                self.locationTimer = nil
            
                
            
                // try to get users location again
                self.getUsersLocation()
                
                //go to settings
//                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))

            presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        alertView.dismissWithClickedButtonIndex(buttonIndex, animated: true)
//        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString))
//    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        DLog("didUpdateLocations")
        
        
        // if no errors do network request
        var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Getting location..."
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0),{
        
            var lastLocation = locations[locations.count-1] as! CLLocation
            var eventInterval = lastLocation.timestamp.timeIntervalSinceNow

            // Make sure this is a recent location event
            DLog("Event Interval: \(eventInterval)")
            if(abs(eventInterval) < 30.0)
            {
                // Make sure the event is accurate enough
                if (lastLocation.horizontalAccuracy >= 0 &&
                    lastLocation.horizontalAccuracy < 50)
                {
                    var here =  lastLocation.coordinate as CLLocationCoordinate2D
                    DLog("\(here.latitude), \(here.longitude)")
                    if self.geocoder == nil {
                        self.geocoder = CLGeocoder()
                    }
    //                
    //                if ([_geocoder isGeocoding])
    //                    [_geocoder cancelGeocode];
                    
                    self.geocoder?.reverseGeocodeLocation(lastLocation, completionHandler: {
                        (placemarks: [AnyObject]!, error: NSError!) in

                        if (placemarks.count > 0)
                        {
                            if let foundPlacemark = placemarks[0] as? CLPlacemark
                            {
    //                            var placeMark = NSMutableDictionary()
    //                            placeMark.setValue(foundPlacemark, forKey: "address")

                                var newLoc = FRLocation(latitude: here.latitude, longtitude: here.longitude, placemark: foundPlacemark.addressDictionary, addressText: nil)
                                
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                
                                AppUtil.saveCustomObjectInUserDefaults(newLoc, key: Constants.Defaults.Location)
                                DLog("Found location = \(newLoc)");
                                
                                AppUtil.updateCurrentLocationInUI(self.fromAddressLabel)
            
                                AppUtil.animateZoom(self.userLocationImageView)
                            }
                            
                        } else if (error.code == CLError.GeocodeCanceled.rawValue) {
                            DLog("Geocoding cancelled");
                        } else if (error.code == CLError.GeocodeFoundNoResult.rawValue) {
                            DLog("No geocoding results found");
                        } else if (error.code == CLError.GeocodeFoundPartialResult.rawValue) {
                            DLog("Partial geocoding result");
                        } else {
                            DLog("unkown error = \(error)");
                        }

                        
                    })

                    self.locationManager?.stopUpdatingLocation()
                }
            }
        })
    }
}
