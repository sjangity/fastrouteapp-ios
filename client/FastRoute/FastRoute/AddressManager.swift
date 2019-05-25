//
//  AddressManager.swift
//  FastRoute
//
//  Created by apple on 8/23/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import Foundation

//extension Array {
//    mutating func removeCustomObject<U: Equatable>(object: U) {
//        var index: Int?
//        for (idx, objectToCompare) in enumerate(self) {
//            if let to = objectToCompare as? U {
//                if object == to {
//                    index = idx
//                }
//            }
//        }
//
//        if((index) != nil) {
//            self.removeAtIndex(index!)
//        }
//    }
//    
//    func contains<T:AnyObject>(item:T) -> Bool {
//        for element in self {
//            if item === element as? T {
//                return true
//            }
//        }
//        return false
//    }
//}

protocol AddressManagerDelegate {
    func waypointsDataResponse(status: Bool)
}

public class AddressManager: NSObject, NSCoding {

    // MARK: singleton
    static var sharedAddressManager: AddressManager?
    
    var delegate: AddressManagerDelegate?
    
//    class func setSharedManager(manager: AddressManager?) {
//        sharedAddressManager = manager
//    }
//    
    class func getSharedManager(forced: Bool = false) -> AddressManager? {
        // TODO: Is this thread-safe?
        if (sharedAddressManager == nil || forced) {
            var manager = loadAddressManagerFromDisk()
            if manager != nil {
                DLog("manager found on disk")
                sharedAddressManager = manager
//                manager?.printData()
                
            } else {
                DLog("vending new manager")
                sharedAddressManager = AddressManager()
            }
            
            // check for tutorial completion handler
            NSNotificationCenter.defaultCenter().addObserver(sharedAddressManager!, selector: "wayPointDirectionsFetched:", name: Constants.NotificationKey.WayPointDirectionsReceivedNotification, object: nil)

            NSNotificationCenter.defaultCenter().addObserver(sharedAddressManager!, selector: "locationDistanceFetched:", name: Constants.NotificationKey.DistanceReceivedNotification, object: nil)

        } else {
            DLog("retrieving cached manager")
        }
        
        return sharedAddressManager
    }

    var addressArray: [FRLocation]! {
        didSet {
            DLog("address update notification")
            hasChanged = true
        }
    }
    var sortedAddressArray: [FRLocation]?
    var fastRoute: [FRWayPoint]?
    var hasChanged: Bool = true
    
    let kAddressArray = "addressArray"
    let kFastRoute = "fastRoute"

    override init() {
        DLog("AddressManager.init")
//        AddressManager.showCacheURL()
        addressArray = [FRLocation]()
        
        super.init()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addAddress(address: FRLocation) {
        addressArray.append(address)
    }
    
    // MARK: NSCoding
    
    required public init(coder aDecoder: NSCoder) {
        super.init()
        DLog("AddressManager.decoding")
        self.addressArray = (aDecoder.decodeObjectForKey(kAddressArray) as! [FRLocation])
        
        // user may have added addresses but quit the application without looking for fast route in which case this will be nil
        if let route = (aDecoder.decodeObjectForKey(kFastRoute) as? [FRWayPoint]) {
            self.fastRoute = route
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        DLog("AddressManager.encoding")
        aCoder.encodeObject(addressArray, forKey: kAddressArray)
        aCoder.encodeObject(fastRoute, forKey: kFastRoute)
    }
    
    // MARK: Persistence/Loading
    
    class func showCacheURL() {
        if let cacheDir = AddressManager.addressManagerCacheDir() {
            if let cacheURL = NSURL(string: Constants.Path.AddressManagerData, relativeToURL: cacheDir) {
                DLog("Cache URL: \(cacheURL.path!)")
            }
        }
    }
    
    class func loadAddressManagerFromDiskTestPath(path: String) -> AddressManager? {

        var result: AddressManager? = nil
        
        var filePath = NSBundle.mainBundle().pathForResource("AddressManagerData", ofType: "txt")
        
        if let data = NSData(contentsOfFile: filePath!) {
//        result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath!) as? AddressManager
            result = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? AddressManager
        }
        
        return result
    }
    
    class func loadAddressManagerFromDisk() -> AddressManager? {
        DLog("AddressManager.loadAddressManagerFromDisk")
        var result: AddressManager? = nil
        if let cacheDir = AddressManager.addressManagerCacheDir() {
            if let cacheURL = NSURL(string: Constants.Path.AddressManagerData, relativeToURL: cacheDir) {
            
                DLog("cacheURL path: \(cacheURL.path!)")
                result = NSKeyedUnarchiver.unarchiveObjectWithFile(cacheURL.path!) as? AddressManager
//                var data = NSData(contentsOfFile: cacheURL.path!)
//                result = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? AddressManager
//                if result == nil {
//                    DLog("Something wrong unarching address manager from disk")
//                }
            }
        }
        return result
    }

    func saveAddressManagerToDisk(notifyDelegate: Bool = false) {
        DLog("AddressManager.saveAddressManagerToDisk")
        var success = false
//        AddressManager.showCacheURL()
        if let cacheDir = AddressManager.addressManagerCacheDir() {
        
            if let cacheURL = NSURL(string: Constants.Path.AddressManagerData, relativeToURL: cacheDir) {
        
                success = NSKeyedArchiver.archiveRootObject(self, toFile: cacheURL.path!)
                if success {
                    printData()
                    DLog("Successfully persisted new addressmanager to disk")
                } else {
                    DLog("Error persisting new addressmanager to disk")
                }
            }
        }

        if notifyDelegate {
            //notify delegate, so it can take appropriate action in UI
            delegate?.waypointsDataResponse(success)
        }
    }

    class func deleteAddressManagerOnDisk() -> Bool {
        DLog("AddressManager.deleteAddressManagerOnDisk")
        var success = false
        
        if let cacheDir = AddressManager.addressManagerCacheDir() {
            if let cacheURL = NSURL(string: Constants.Path.AddressManagerData, relativeToURL: cacheDir) {
                var error: NSError?
                var fileManager = NSFileManager.defaultManager()
                success = fileManager.removeItemAtURL(cacheURL, error: &error)
            }
        }
        return success
    }
    
    class func addressManagerCacheDir() -> NSURL? {
        var fileManager = NSFileManager.defaultManager()
        var cacheDirArray = fileManager.URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as! [NSURL]
        var cacheDir = cacheDirArray.last
        
        if let url = NSURL(string: "JSONResponses/", relativeToURL: cacheDir) {
            var error: NSError?
            
            // does directory exist, create if not
            if !fileManager.fileExistsAtPath(url.path!) {
                fileManager.createDirectoryAtPath(url.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
            }
            
            return url
        }
        
        return nil
    }
    
    func printData() {
        DLog("Printing address manager data")
        DLog("Loaded addresses:")
        if let addresses = addressArray {
            for address : FRLocation in addresses {
                DLog("Address Text: \(address.addressText!)")
            }
        }
        DLog("Loaded waypoints:")
        var count = 0
        if let waypoints = fastRoute {
            count = waypoints.count
            
            for waypoint : FRWayPoint in waypoints {
                DLog(waypoint.description)
                var steps = waypoint.steps
                DLog(steps.description)
            }
        }
    }
    
    // MARK: Directions
    func wayPointDirectionsFetched(notification: NSNotification) {
        DLog("Directions fetched")
        printData()
        if loadDirectionsFromDisk() {
            DLog("Directions JSON parse complete. Pushing changes to address manager on disk")
            saveAddressManagerToDisk(notifyDelegate: true)
        }
    }
    
    func loadDirectionsFromDisk() -> Bool {
        var loaded: Bool = false
        
        if let jsonDict = TCServiceCommunicator.sharedCommunicator().getJSONFromDiskWithClassName("Directions") as? [String: AnyObject] {
            if let jsonResult = jsonDict["result"] as? [String: AnyObject] {
                
                fastRoute = [FRWayPoint]()
                
                // parse json
                if let waypoints = jsonResult["waypoints"] as? [AnyObject] {
                    for waypoint in waypoints {
                    
                        let address = waypoint["address"] as! Dictionary<String,AnyObject>
                        let startAddress = address["startAddress"] as! Dictionary<String, AnyObject>
                        let endAddress = address["endAddress"] as! Dictionary<String, AnyObject>
                    
                        var startLocation = FRLocation(latitude: startAddress["latitude"] as! Double, longtitude: startAddress["longtitude"] as! Double, placemark: nil, addressText: startAddress["addressText"] as? String)
                        var endLocation = FRLocation(latitude: endAddress["latitude"] as! Double, longtitude: endAddress["longtitude"] as! Double, placemark: nil, addressText: endAddress["addressText"] as? String)
                    
//                        let startAddress = waypoint["startAddress"] as! String
//                        let endAddress = waypoint["endAddress"] as! String
                        let distance = waypoint["distance"] as! Int
                        let duration = waypoint["duration"] as! Int
                    
                        var newWayPoint = FRWayPoint(startAddress: startLocation, endAddress: endLocation, distance: distance, duration: duration)
                        
                        if let steps = waypoint["steps"] as? [AnyObject] {
                            for step in steps {
                                let stepDistance = step["distance"] as! Int
                                let stepDuration = step["duration"] as! Int
                                let stepText = step["text"] as! String
                                let stepPolyline = step["polyline"] as! String
                                

                                let stepAddress = step["address"] as! Dictionary<String,AnyObject>
                                let stepStartAddress = stepAddress["startAddress"] as! Dictionary<String, AnyObject>
                                let stepEndAddress = stepAddress["endAddress"] as! Dictionary<String, AnyObject>
                                var stepStartLocation = FRLocation(latitude: stepStartAddress["latitude"] as! Double, longtitude: stepStartAddress["longtitude"] as! Double, placemark: nil, addressText: stepStartAddress["addressText"] as? String)
                                var stepEndLocation = FRLocation(latitude: stepEndAddress["latitude"] as! Double, longtitude: stepEndAddress["longtitude"] as! Double, placemark: nil, addressText: stepEndAddress["addressText"] as? String)
                                
                                newWayPoint.addStep(stepStartLocation, endAddress: stepEndLocation,distance: stepDistance, duration: stepDuration, text: stepText, polyline: stepPolyline)
                            }
                        }
                        
                        fastRoute?.append(newWayPoint)
                    }

                    loaded = true
                } else {
                    DLog("No waypoints to parse")
                }
            } else {
                DLog("no result found in json response")
            }
        } else {
            DLog("unable to parse json from file")
        }
        
        return loaded
    }
    
    // MARK: Map Calculations
    
    func sortedByDistance(location1: FRLocation, location2: FRLocation) -> Bool {
        return location1.distanceFromOrigin < location2.distanceFromOrigin
    }
    
    func removeAddress(address: FRLocation) {
        self.addressArray = self.addressArray.filter ( {$0 != address} )
    }
    
    func findBestRoute(rootLocation: FRLocation, nodeLocations: [FRLocation]) -> FRLocation? {
        // ALGO
        // 1. set source root location
        // 2. get distance from source to all other terminal locations
        // 3. find closest terminal location from source root location
        // 4. find directions from source->closest terminal
        // 5. set closest terminal as new source root and repeat steps 1-4 until all locations have directions
        
        if nodeLocations.count == 0 {
            return nil
        }
        
//        // compute distances from root location
//        for destLocation: FRLocation in nodeLocations {
//            var distance = AppUtil.calcDistance0(rootLocation.latitude, longtitude1: rootLocation.longtitude, latitude2: destLocation.latitude, longtitude2: destLocation.longtitude)
//            destLocation.distanceFromOrigin = distance
//        }
        
        // find next closest location
        let nextRootLocation = nodeLocations.reduce(nodeLocations[0]) {
            ($0.distanceFromOrigin < $1.distanceFromOrigin) ? $0 : $1
        }
        
        nextRootLocation.previousLocation = rootLocation
        
        // update directions for getting to next root location
        sortedAddressArray?.append(nextRootLocation)

        // remove nextRoot from nodes to search on next pass
//        var copyAddresses = nodeLocations.map { $0.copy() }
//        if let index = find(nodeLocations, nextRootLocation) {
//            copyAddresses.removeAtIndex(index)
//        }
        var moreLocations = nodeLocations // get mutable copy of immutable copy
//// func find<C : CollectionType where C.Generator.Element : Equatable>(domain: C, value: C.Generator.Element) -> C.Index?
        if let index = find(nodeLocations, nextRootLocation) {
           moreLocations.removeAtIndex(index)
        }
        
        // recurse to all other nodes
        return findBestRoute(nextRootLocation, nodeLocations: moreLocations)
    }
    
    func displayAddresses() {
        for address: FRLocation in self.addressArray {
//            DLog("\(address.addressText)")
            DLog(address.description);
        }
    }
    
    func getwaypoints(addresses: [FRLocation]) -> String {
        var waypoints: String = ""
        var mutableAddresses = addresses
        if addresses.count > 2 {
            // pop off first/last from array as they are origin/destination in directions API
            mutableAddresses.removeLast()
            mutableAddresses.removeAtIndex(0)
            
            for wayPointAddress : FRLocation in mutableAddresses {
                waypoints += "\(wayPointAddress.latitude),\(wayPointAddress.longtitude)|"
            }
        }
        
        return waypoints
    }
    
    func bestRoute(currentLocation rootLocation: FRLocation, nodeLocations: [FRLocation]) {

        var startLocationMatrix = CLLocationCoordinate2D(latitude: rootLocation.latitude, longitude: rootLocation.longtitude)


        var locationsNeedingDistanceCalc = [FRLocation]()

        // compute distances from root location
        for destLocation: FRLocation in nodeLocations {
//            var distance = AppUtil.calcDistance0(rootLocation.latitude, longtitude1: rootLocation.longtitude, latitude2: destLocation.latitude, longtitude2: destLocation.longtitude)
            
            var endLocationMatrix = CLLocationCoordinate2D(latitude: destLocation.latitude, longitude: destLocation.longtitude)
            
            var distance = GMSGeometryDistance(startLocationMatrix, endLocationMatrix)
            
            if distance/1609.34 < 1 {
                DLog("Distance calculation requires google lookup: address \(destLocation)")
                
                // make network request so distanceFromOrigin can be updated in network callback
//                NetworkClient.sharedClient.getDistance(rootLocation, destination: destLocation)
                locationsNeedingDistanceCalc.append(destLocation)
            } else {
                DLog("Distance calculation does not require google lookup: address \(destLocation)")

                destLocation.distanceFromOrigin = distance
            }
        }
        
        if locationsNeedingDistanceCalc.count > 0 {
            NetworkClient.sharedClient.getDistance(rootLocation, destinations: locationsNeedingDistanceCalc)
        } else {
            computeFastRoute()
        }
    }
    
    func shouldWaitUntilAllDistancesAreCalculated() -> Bool {
        var result: Bool = true
        for address: FRLocation in self.addressArray {
            if address.distanceFromOrigin == nil {
                result = false
                break
            }
        }
        return result
    }
    
    // method is called multiple times
    func computeFastRoute() {
        if let location = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
        
            // TODO: if previous sorted array exists, remove its references so no memory is leaked
            if sortedAddressArray != nil {
                sortedAddressArray = nil
            }
            
            // get best route
            sortedAddressArray = [FRLocation]()
            sortedAddressArray?.append(location) // add current location at root of route

            findBestRoute(location, nodeLocations: self.addressArray)

            // update route with directions
            if let sortedArray = sortedAddressArray {
                let origin = location
                if let destination = sortedAddressArray?.last {
                    let waypoints = getwaypoints(sortedArray)

                    // Download directions of route
                    NetworkClient.sharedClient.getDirections(origin, destination: destination, waypoints: waypoints)
                }
            }
        }
    }
    
    func locationDistanceFetched(notification: NSNotification)
    {
        DLog("locationDistanceFetched delegate method")
        var continueFastRouteAlgo = shouldWaitUntilAllDistancesAreCalculated()
        if continueFastRouteAlgo {
        
            DLog("Completed fetching all distances")
            computeFastRoute()
        }
    }
//    
//    func bestRoute(currentLocation location: FRLocation, addresses: [FRLocation]) {
//        
//        // compute distances to nodes if distance is not accurate (<1 mile apart)
//        self.computeDistances(currentLocation: location, nodeLocations: addresses)
//
//    }
}
