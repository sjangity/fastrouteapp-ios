//
//  AppUtil.swift
//  FastRoute
//
//  Created by apple on 8/19/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import SystemConfiguration
import AddressBook

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIButton {
    func styled() {
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        let l : CALayer = self.layer
//        l.backgroundColor=UIColor.greenColor().CGColor
//        l.backgroundColor = UIColor(rgb: 0x81B184).CGColor
        l.backgroundColor = UIColor(rgb: 0x0B4561).CGColor
        l.masksToBounds = true
        l.cornerRadius = 5
        l.borderWidth = 1
//        l.borderColor = UIColor(red: 0.0, green: 122.0/2550, blue: 1.0, alpha: 1.0).CGColor
    }
    
    func styledGreen() {
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        let l : CALayer = self.layer
//        l.backgroundColor=UIColor.greenColor().CGColor
        l.backgroundColor = UIColor(rgb: 0x81B184).CGColor
//        l.backgroundColor = UIColor(rgb: 0x0B4561).CGColor
        l.masksToBounds = true
        l.cornerRadius = 5
        l.borderWidth = 1
//        l.borderColor = UIColor(red: 0.0, green: 122.0/2550, blue: 1.0, alpha: 1.0).CGColor
    }
    
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class AppUtil: NSObject {

    class func getGMSKeyToken() -> String {
        //TODO: enable stronger check so production access token for google APIs is never leaked or misused
        var token = "AIzaSyDaL3IizotTRZxOE4E_SFV1tXkGbVBU4VA"
        var enableGMSKey = AppUtil.readValueFromConfigration(Constants.API.kEnableGMSKey) as! Bool
        if enableGMSKey == true {
            token = "AIzaSyCEQupHLPaAlw22hqMFKxz595oaiUlqipc"
        }
        return token
    }

    class func updateCurrentLocationInUI(fromAddressLabel: UILabel) {
        if let location = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {

            if location.addressText == nil {
                // users location doesn't have reverse geocode, so let's go get it
                if let placemark = location.placemark {
//                    var addressDictionary = placemark.valueForKeyPath("addressDictionary")
                    
                    if let street = placemark["Name"] as? String {
                        // if street is available and parseable, let's assume the others are as well
                        var zip = placemark[kABPersonAddressZIPKey] as? String
                        var city = placemark[kABPersonAddressCityKey] as? String
                        var state = placemark[kABPersonAddressStateKey] as? String
                        var formattedAddressLine=placemark["FormattedAddressLines"] as? [String]
                    
                        var addressText = "\(street), \(city!), \(state!) \(zip!)"
                        location.addressText = addressText
                        
                        // save location address to disk
                        AppUtil.saveCustomObjectInUserDefaults(location, key: Constants.Defaults.Location)
                    }
                }
            }
            
            fromAddressLabel.text = location.addressText
        }
    }

    class func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class func parseAddress(str: String) -> [NSObject : AnyObject] {
        var error: NSError?
        var addressDictionary: [NSObject : AnyObject]!
        var addDetector = NSDataDetector(types: NSTextCheckingType.Address.rawValue, error: &error)
        if let addDetector = addDetector {
        //    addDetector.enumerateMatchesInString(addressTest, options: nil, range: NSMakeRange(0, (addressTest as NSString).length), usingBlock: { (result: NSTextCheckingResult!, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
        //        DLog(result.addressComponents)
        //    })
            let matchs = addDetector.matchesInString(str, options: nil, range: NSMakeRange(0, (str as NSString).length))
            for match in matchs {
                let matchRange = match.range
                if match.resultType == NSTextCheckingType.Address {
                    addressDictionary = match.addressComponents //as! [String : String]
//                    DLog("matches = \(match.addressComponents)")
                }
            }
        }
        return addressDictionary
    }

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }

        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }

        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        return isReachable && !needsConnection
    }

    class func checkNetworkStatus(vc: UIViewController) -> Bool {
//        var attempts = 0
//        var connected = true
//        while (attempts < 3) {
//            connected = !TCReachabilityManager.sharedManager().isUnreachable()
//            if !connected {
//                attempts += 1
//            } else {
//                attempts = 100 // break the loop
//            }
//        }
        var connected = AppUtil.isConnectedToNetwork()
        
//        DLog("network status - \(connected)")
        if !connected {
            connected = false
            
            var alertTitle = "Network Error"
            var alertMessage = "Please check your network connection and try again."
            
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) in
//                DLog("You pressed a button")
            })
            alert.addAction(defaultAction)
            vc.presentViewController(alert, animated: true, completion: nil)
        }
        return connected
    }

    class func saveCustomObjectInUserDefaults(object: AnyObject, key: String) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: key);
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    class func loadCustomObjectFromUserDefaults(key: String) -> AnyObject? {
        var result: AnyObject? = nil
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData {
            result = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        }
        return result
    }
    
    class func readValueFromConfigration(key: String) -> AnyObject? {
        var result: AnyObject?
        var bundle = NSBundle.mainBundle()
        var path = bundle.pathForResource("Configuration", ofType: "plist")
        if let dict = NSDictionary(contentsOfFile: path!) {
            result = dict.objectForKey(key)
        }
        return result
    }
    
    class func setRoundedBorder(radius : CGFloat, withBorderWidth borderWidth: CGFloat, withColor color : UIColor, forButton button : UIButton)
    {
        let l : CALayer = button.layer
        l.masksToBounds = true
        l.cornerRadius = radius
        l.borderWidth = borderWidth
        l.borderColor = color.CGColor
    }
    
    // MARK: Location based calculations
    class func DegreesToRadians(degrees: Double ) -> Double {
        return degrees * M_PI / 180
    }

    class func RadiansToDegrees(radians: Double) -> Double {
        return radians * 180 / M_PI
    }
    
    
    class func calcDistance4(latitude1: Double, longtitude1: Double, latitude2: Double, longtitude2: Double) -> Double {
        // http://www.movable-type.co.uk/scripts/latlong.html
        // http://williams.best.vwh.net/avform.htm#Example

        // d=2*asin(sqrt((sin((lat1-lat2)/2))^2 + cos(lat1)*cos(lat2)*(sin((lon1-lon2)/2))^2))

        var lat1 = AppUtil.DegreesToRadians(latitude1)
        var lat2 = AppUtil.DegreesToRadians(latitude2)

        var long1 = AppUtil.DegreesToRadians(longtitude1)
        var long2 = AppUtil.DegreesToRadians(longtitude2)

//        DLog("lat1: \(lat1), long1: \(long1)")
//        DLog("lat2: \(lat2), long2: \(long2)")
        
        // a = sin(( (lat1-lat2)/2 ) )^2
        var a = sin((lat1-lat2)/2)
//        DLog ("sin((lat1-lat2)/2): \(a)")
        
        // b = cos(lat1)
        var b = cos(lat1)
//        DLog ("cos(lat1): \(b)")
        
        // c = cos(lat2)
        var c = cos(lat2)
//        DLog ("cos(lat2): \(c)")
        
        // d = (sin((lon1-lon2)/2))^2)
        var d = sin((long1-long2)/2)
//        DLog ("sin((long1-long2)/2): \(d)")
        
        var result = RadiansToDegrees(2 * asin ( sqrt ( pow(a, 2) + b * c * pow(d, 2) ) ) * 60)
        
        return result // nautical miles
    }
    
    class func calcDistance3(latitude1: Double, longtitude1: Double, latitude2: Double, longtitude2: Double) -> Double {
        // http://www.movable-type.co.uk/scripts/latlong.html

        // a = sin(( (lat1-lat2)/2 ) )^2
        var nLat = DegreesToRadians(latitude1-latitude2)
        var a = pow ( sin(nLat/2), 2)
        
        // b = cos(lat1)
        var lat1 = DegreesToRadians(latitude1)
        var b = cos(lat1)
        
        // c = cos(lat2)
        var lat2 = DegreesToRadians(latitude2)
        var c = cos(lat2)
        
        // d = (sin((lon1-lon2)/2))^2)
        var nLong = DegreesToRadians(longtitude1-longtitude2)
        var d = (pow ( sin(nLong/2), 2))
        
        var nLon = DegreesToRadians(longtitude1-longtitude2)
        var result = 2 * asin ( sqrt (a + b * c * d) )

        // d=2*asin(sqrt((sin((lat1-lat2)/2))^2 + cos(lat1)*cos(lat2)*(sin((lon1-lon2)/2))^2))
        
        return result * Constants.Haversine.kHaversineFPerMI
    }
    
    class func calcDistance2(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        // https://github.com/100grams/CoreLocationUtils/blob/master/CoreLocationUtils/CLLocation%2Bmeasuring.m
        
        // Get the difference between our two points then convert the difference into radians
        var nDLat = (lat2 - lat1) * Constants.Haversine.kDegreesToRadians
        var nDLon = (long2 - long1) * Constants.Haversine.kDegreesToRadians
        
        var fromLat =  lat1 * Constants.Haversine.kDegreesToRadians
        var toLat =  lat2 * Constants.Haversine.kDegreesToRadians
        
        var nA =	pow ( sin(nDLat/2), 2 ) + cos(fromLat) * cos(toLat) * pow ( sin(nDLon/2), 2 )
        
        var nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ))
//        DLog("nC = \(nC)")
        var nD = Constants.Haversine.kHaversineKMRadius * nC
//        DLog("nD = \(nD)")
        return nD / 1609.34 // Return our calculated distance in meters
    }
    
    class func calcDistance1(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        let lat1Rad = lat1 * Constants.Haversine.kHaversineRadsPerDegree
        let lat2Rad = lat2 * Constants.Haversine.kHaversineRadsPerDegree
        let dLonRad = ((long2 - long1) * Constants.Haversine.kHaversineRadsPerDegree)
        let dLatRad = ((lat2 - lat1) * Constants.Haversine.kHaversineRadsPerDegree)
        let a = pow(sin(dLatRad / 2), 2) + cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLonRad / 2), 2)
        return (2 * atan2(sqrt(a), sqrt(1 - a))) * Constants.Haversine.kHaversineFPerMI
    }
    
    class func calcDistance0(latitude1: Double, longtitude1: Double, latitude2: Double, longtitude2: Double) -> Double {

        var location1 = CLLocation(latitude: latitude1, longitude: longtitude1)
        var location2 = CLLocation(latitude: latitude2, longitude: longtitude2)
        var distance = location1.distanceFromLocation(location2)

        return distance / 1609.34
    }
    
    // MARK: Bearings
    class func bearingToLocationRadian(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Double {
        let lat1 = DegreesToRadians(lat1)
        let long1 = DegreesToRadians(long1)
        
        let lat2 = DegreesToRadians(lat2)
        let long2 = DegreesToRadians(long2)

        let dLon = long2 - long1

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x)

        return radiansBearing
    }
    
    // MARK: Animations
    
    class func animateZoom(view: UIView) {
        view.transform = CGAffineTransformMakeScale(1.5, 1.5);
        view.alpha = 0;
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            view.transform = CGAffineTransformMakeScale(1, 1);
            view.alpha = 1;
        }) { (bool: Bool) -> Void in
            AppUtil.animateShake(view)
        }
    }
    
    class func animateShake(view: UIView) {
        view.transform = CGAffineTransformMakeTranslation(0, 0)
        UIView.animateWithDuration(1.5/5, delay: 0.2, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            view.transform = CGAffineTransformMakeTranslation(30, 0)
        }) { (bool: Bool) -> Void in
            // completion (BEGIN)
           UIView.animateWithDuration(1.5/5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                view.transform = CGAffineTransformMakeTranslation(-30, 0)
            }) { (bool: Bool) -> Void in
                // completion
                UIView.animateWithDuration(1.5/5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    view.transform = CGAffineTransformMakeTranslation(15, 0)
                }) { (bool: Bool) -> Void in
                    // completion
                    UIView.animateWithDuration(1.5/5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        view.transform = CGAffineTransformMakeTranslation(-15, 0)
                    }) { (bool: Bool) -> Void in
                        // completion
                        UIView.animateWithDuration(1.5/5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                            view.transform = CGAffineTransformMakeTranslation(0, 0)
                        }) { (bool: Bool) -> Void in
                            // completion (END)
                        }
                    }
                }
            }
        }
    }
}
