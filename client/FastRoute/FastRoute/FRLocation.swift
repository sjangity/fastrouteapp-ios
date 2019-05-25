//
//  FRLocation.swift
//  FastRoute
//
//  Created by apple on 8/20/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class FRLocation: NSObject, NSCoding {
    var latitude: Double
    var longtitude: Double
    var placemark: [NSObject : AnyObject]?
    var addressText: String?
    var distanceFromOrigin: Double? // expressed in miles in math calc
    var distanceInMiles: String? {
        get {
            var result: String?
            if let distance = distanceFromOrigin {
                let divisor = pow(10.0, Double(2))
                let rounded = round(distance * divisor) / divisor
                result = "\(rounded) miles"
            }
            return result
        }
    }
    
    var previousLocation: FRLocation?
    var directions: [String]?
//    var waypoints: [FRWayPoint]?
    
    let kLatitudeKey = "latitude"
    let kLongtitudeKey = "longtitude"
    let kPlacemarkKey = "placemark"
    let kAddressTextKey = "addressText"
    let kAddressDistanceFromOrigin = "distanceFromOrigin"
    
    init(latitude: Double, longtitude: Double, placemark: [NSObject : AnyObject]?, addressText: String?) {
        self.latitude = latitude
        self.longtitude = longtitude
        if let placemark = placemark {
            self.placemark = placemark
        }
        if let addressText = addressText {
            self.addressText = addressText
        }
        super.init()
    }
    
    override var description: String {
        return "\(latitude),\(longtitude) - \(addressText)"
    }
    
    var apiDescription: String {
        return "\(latitude),\(longtitude)"
    }
    
    // NSCoder Protocol methods
    
    required init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeObjectForKey(kLatitudeKey) as! Double
        self.longtitude = aDecoder.decodeObjectForKey(kLongtitudeKey) as! Double
        self.placemark = aDecoder.decodeObjectForKey(kPlacemarkKey) as? [NSObject : AnyObject]
        self.addressText = aDecoder.decodeObjectForKey(kAddressTextKey) as? String
        self.distanceFromOrigin = aDecoder.decodeObjectForKey(kAddressDistanceFromOrigin) as? Double
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(latitude, forKey: kLatitudeKey)
        aCoder.encodeObject(longtitude, forKey: kLongtitudeKey)
        aCoder.encodeObject(placemark, forKey: kPlacemarkKey)
        aCoder.encodeObject(addressText, forKey: kAddressTextKey)
        aCoder.encodeObject(distanceFromOrigin, forKey: kAddressDistanceFromOrigin)
        // don't encode images in archives, store a name to the image file on disk
    }
}
