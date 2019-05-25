//
//  NewAddressViewController.swift
//  FastRoute
//
//  Created by apple on 9/8/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

protocol NewAddressViewDelegate {
    func newAddressAdded(location: FRLocation)
}

class NewAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var popUpView: UIView!
    var location: FRLocation?
    var delegate: NewAddressViewDelegate?
    var addressManager: AddressManager?
    var currentLocationPredictions: [GMSAutocompletePrediction]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)

        // Do any additional setup after loading the view.

        textField.delegate = self
                
        autocompleteTableView.dataSource = self
        autocompleteTableView.delegate = self
//        autocompleteTableView.tableFooterView = UIView(frame: CGRectZero)
        
        currentLocationPredictions = [GMSAutocompletePrediction]()
        
        // check for tutorial completion handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onFetchGoogleAutocomplete:", name: Constants.NotificationKey.AddressAutocompleteNotification, object: nil)

        // check for new autocomplete address network call complete and pushed to disk message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newAutocompleteAddressSelected:", name: Constants.NotificationKey.AddressAutocompleteSelectedNotification, object: nil)
        
//        addressManager = AddressManager()
        
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Popup Handlers
    func showInView(aView: UIView!)
    {
//        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
//        DLog("showInView")
//        DLog(view.frame)
//        DLog(view.bounds)
        view.frame = CGRectMake(0,0, aView.frame.size.width, aView.frame.size.height)
//        view.frame = view.bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        aView.addSubview(self.view)
        self.showAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }

    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
    

    // Text View Delegates

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        DLog("shouldchangecharcters")

        if count(textField.text) > 10 {
            // make call to google autocomplete api
            NetworkClient.sharedClient.placeAutoComplete(textField.text)
        }
        return true
    }

    func onFetchGoogleAutocomplete(notification: NSNotification) {
        DLog("notificiation recieved")
        currentLocationPredictions = notification.userInfo?["results"] as? [GMSAutocompletePrediction]
        DLog("Reload tableview")
        autocompleteTableView.reloadData()
    }
    
    // Table View Datasource / Delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = currentLocationPredictions.count
//        DLog("rows in table: \(count)")
        return count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
    
        var prediction = currentLocationPredictions[indexPath.row] as GMSAutocompletePrediction
        let regularFont = UIFont.systemFontOfSize(12)
        let boldFont = UIFont.boldSystemFontOfSize(12)

        let bolded = prediction.attributedFullText.mutableCopy() as! NSMutableAttributedString
        bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: nil) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
          let font = (value == nil) ? regularFont : boldFont
          bolded.addAttribute(NSFontAttributeName, value: font, range: range)
        }
    
        cell.textLabel?.attributedText = bolded
    
        return cell
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        DLog("NewAddress.didSelectRowAtIndexPath")
        var selectedAddress = currentLocationPredictions[indexPath.row] as GMSAutocompletePrediction

        // grab geocodes from selectedAddress which hapepns on background thread
        DLog("Downloading geocode info for autocomplete address")
        NetworkClient.sharedClient.getAutocompleteGeocode(selectedAddress.attributedFullText.string, entityName: "Address-Auto")
    }

    func newAutocompleteAddressSelected(notification: NSNotification) {
        DLog("Retrieve geocode from address saved to disk")
        if let jsonDict = NetworkClient.sharedClient.communicator?.getJSONFromDiskWithClassName("Address-Auto") as? [String: AnyObject]
        
        {
            DLog("JSON DICT")
            DLog(jsonDict.description)
            
            // result
                // address
                // latitude
                // longtitude
            
            if let jsonLocation = jsonDict["result"] as? [String: AnyObject] {
            
                if let latitude = jsonLocation["latitude"] as? Double {
                    if let longtitude = jsonLocation["longtitude"] as? Double {
                        if let addressText = jsonLocation["address"] as? String {

                            // new location
                            var location = FRLocation(latitude: latitude, longtitude: longtitude, placemark: nil, addressText: addressText)
                            
                            // compute distance from current location to new location
                            if let userLocation = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
                                var distance = AppUtil.calcDistance0(userLocation.latitude, longtitude1: userLocation.longtitude, latitude2: location.latitude, longtitude2: location.longtitude)
                                location.distanceFromOrigin = distance
                            }
                            
//                            // add new location to address manager
//                            addressManager?.addAddress(location)
//                            addressManager?.saveAddressManagerToDisk()
                            
                            // save location to current searched addresses on disk
//                            NetworkClient.sharedClient.communicator?.saveAddressJSONResponseToDisk(data, withEntityName: Constants.Path.CurrentRoutesearchAddresses, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
            
                            // notify delegate which will remove address from view
                            self.delegate?.newAddressAdded(location)
                            
                        }
                    }
                }
            }
        }    
    }
    
}
