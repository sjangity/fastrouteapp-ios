//
//  API.swift
//  FastRoute
//
//  Created by apple on 8/26/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import Foundation

// GLobal Constants
let kHost = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
let kHostPartial = AppUtil.readValueFromConfigration(Constants.API.kHostPartial) as! String
let kAPIVersion = AppUtil.readValueFromConfigration(Constants.API.kAPIVersion) as! String
let kAPISecret = "MU3IO2-ABOUK183030190-AUB5678890912"

// DO NOT MODIFY
let kGMSPlacesAPIKey = AppUtil.getGMSKeyToken()

// Make constant accessible from Objective-C
@objc class GlobalConstant {
    private init() {}
    
    class func kHostString() -> String { return kHost; }
    class func kHostPartialString() -> String { return kHostPartial; }
    class func kAPIVersionString() -> String { return "1.0"; }
    class func kAPISecretString() -> String { return kAPISecret; }
}

struct Constants {

    struct NotificationKey {
        static let TutorialFinishedNotification = "FirstTimeTutorialCompleteNotification"
        static let AddressAutocompleteNotification = "AddressAutocompleteNotification"
        static let AddressAutocompleteSelectedNotification = "AddressAutocompleteSelectedNotification"
        static let WayPointDirectionsReceivedNotification = "WayPointDirectionsReceivedNotification"
        static let AddressReverseGeocodingNotification = "AddressReverseGeocodingNotification"
        static let DistanceReceivedNotification = "DistanceReceivedNotification"
    }
    
    struct Path {
        static let Tmp = NSTemporaryDirectory()
        static let CurrentRoutesearchAddresses = "CurrentRoutesearchAddresses"
        static let AddressManagerData = "AddressManagerData.txt"
    }
    
    struct Defaults {
        static let Location = "location"
    }
    
    struct Unit {
        static var kViewDidAppearKey = "ViewControllerTestsViewDidAppearKey"
        static var kViewWillDisappearKey = "ViewControllerTestsViewWillDisappearKey"
        static var kViewControllerTestsViewDidLoadKey = "ViewControllerTestsViewDidLoadKey"
    }

    struct API {
        static var kHost = "kHost"
        static var kHostPartial = "kHostPartial"
        static var kAPIVersion = "kAPIVersion"
        static var kEnableGMSKey = "kEnableGMSKey"
    }
    
    struct Haversine {
        static var kHaversineRadsPerDegree : Double = 0.0174532925199433
        static var kHaversineMIRadius : Double = 3956.0
        static var kHaversineKMMeanRadius : Double = 6371.01 // earth mean radius in KM's
        static var kHaversineKMRadius : Double = 6371000
        static var kHaversineMPerKM : Double = 1000.0
        static var kHaversineFPerMI : Double = 5282.0
        
        static var kDegreesToRadians : Double = M_PI / 180.0
        static var kRadiansToDegrees : Double = 180.0 / M_PI
    }
}