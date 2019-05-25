//
//  AddressManagerTests.swift
//  FastRoute
//
//  Created by apple on 8/31/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import XCTest
import FastRoute

class AddressManagerTests: BaseViewControllerTests {

    var addressManager: AddressManager?

    override func setUp() {
        super.setUp()

        AddressManager.deleteAddressManagerOnDisk()
        
//        var someDelegate = UIApplication.sharedApplication().delegate
//        if let appDelegate =  someDelegate as? AppDelegate //EXC_BAD_ACCESS here {
//            addressManager = appDelegate
//        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        if let manager = delegate.addressManager as? AddressManager {
//            addressManager = manager
//        }
//        addressManager = AddressManager()
        
        addressManager = AddressManager.getSharedManager()
//        }
        
        println("setup complete")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        println("teardown")
        
        addressManager = nil
        
        AddressManager.deleteAddressManagerOnDisk()
    }

    func loadDefaultAddresses() {
        // Simulates the address data that would otherwise be entered manually in the UI prior to finding the best route
   
        var destLoc1 = FRLocation(latitude: 37.3586992, longtitude: -122.0318482, placemark: nil, addressText: "1040 Sunnyvale Saratoga Road, Sunnyvale, CA 94087") // 5 minutes, 1.8 miles

//        var destLoc2 = FRLocation(latitude: 37.364556, longtitude: -122.030719, placemark: nil, addressText: "150 East El Camino Real, Sunnyvale, CA 94087") // 3 minutes, 1.1 miles
        
        var destLoc2 = FRLocation(latitude: 37.3533959, longtitude: -122.04021, placemark: nil, addressText: "676 Conway Rd, Sunnyvale, CA 94087, USA") // 2 minutes, 0.8 miles
        
//        var destLoc3 = FRLocation(latitude: 38.9200098, longtitude: -119.994204, placemark: nil, addressText: "2236 Lake Tahoe Blvd, South Lake Tahoe, CA 96150") // 3 hours 44 minutes, 218 miles

        addressManager?.addAddress(destLoc1)
        addressManager?.addAddress(destLoc2)
        addressManager?.saveAddressManagerToDisk()
    }
    
    func loadDefaultLocation() {
        var currentLocation = FRLocation(latitude: 37.363907, longtitude: -122.041826, placemark: nil, addressText: "1842 N Shoreline Blvd, Mountain View, CA 94043")
        
        AppUtil.saveCustomObjectInUserDefaults(currentLocation, key: Constants.Defaults.Location)
        if let location = AppUtil.loadCustomObjectFromUserDefaults(Constants.Defaults.Location) as? FRLocation {
            println(location)
        }
    }
    
    
    
    
    
    
    
    // MARK: Non-networked Tests
    
    func testSavingLoadingAddressManagerToDisk() {
        loadDefaultAddresses()
        
        var count = 0
        if let addresses = addressManager?.addressArray {
            count = addresses.count

            for address : FRLocation in addresses {
                println("Address Text: \(address.addressText!)")
            }
        }
        println("# of addresses found: \(count)")
               
//        addressManager?.deleteAddressManagerOnDisk()
        
        XCTAssertTrue(count == 2, "There should be addresses loaded into memory")
    }

    
    func testCalculateDistance() {
        loadDefaultAddresses()
        
        var currentLocation = FRLocation(latitude: 37.363907, longtitude: -122.041826, placemark: nil, addressText: "1842 N Shoreline Blvd, Mountain View, CA 94043")
        var startLocationMatrix = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longtitude)

        if let addresses = addressManager?.addressArray {
            for destLocation: FRLocation in addresses {
                var endLocationMatrix = CLLocationCoordinate2D(latitude: destLocation.latitude, longitude: destLocation.longtitude)
            
                var distance = GMSGeometryDistance(startLocationMatrix, endLocationMatrix)
                
//                var distance = AppUtil.calcDistance0(currentLocation.latitude, longtitude1: currentLocation.longtitude, latitude2: destLocation.latitude, longtitude2: destLocation.longtitude)
//                var distance = AppUtil.calcDistance1(currentLocation.latitude, long1: currentLocation.longtitude, lat2: destLocation.latitude, long2: destLocation.longtitude)
//                var distance = AppUtil.calcDistance2(currentLocation.latitude, long1: currentLocation.longtitude, lat2: destLocation.latitude, long2: destLocation.longtitude)
//                var distance = AppUtil.calcDistance3(currentLocation.latitude, longtitude1: currentLocation.longtitude, latitude2: destLocation.latitude, longtitude2: destLocation.longtitude)
                println("Location: \(destLocation.addressText), Distance = \(distance/1609.34) miles")
            }
        }
    }











    // MARK: Networked Tests

    func testGetDistance() {
        loadDefaultAddresses()
        
        var currentLocation = FRLocation(latitude: 37.363907, longtitude: -122.041826, placemark: nil, addressText: "1842 N Shoreline Blvd, Mountain View, CA 94043")
        var startLocationMatrix = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longtitude)

        if let addresses = addressManager?.addressArray {
            for destLocation: FRLocation in addresses {
                var endLocationMatrix = CLLocationCoordinate2D(latitude: destLocation.latitude, longitude: destLocation.longtitude)
            
                var distance = GMSGeometryDistance(startLocationMatrix, endLocationMatrix)

                if distance/1609.34 < 1 {
                    // make network request
//                    addressManager?.getDistanceRemote(currentLocation, destinationLocation: destLocation)
                    
                    self.delayExecution(3)
                }
                
                println("Location: \(destLocation.addressText), Distance = \(distance/1609.34) miles")
            }
        }
        
        println("Loading routes:")
        if let addresses = addressManager?.addressArray {
            for address : FRLocation in addresses {
                println("Address Text: \(address.addressText), Distance: \(address.distanceFromOrigin!)")
            }
        }
    }
    
    func testBestRoute() {
        loadDefaultLocation()
    
        loadDefaultAddresses()
    
        var currentLocation = FRLocation(latitude: 37.363907, longtitude: -122.041826, placemark: nil, addressText: "1842 N Shoreline Blvd, Mountain View, CA 94043")

        if let addresses = addressManager?.addressArray {
        
            // network request to download 'Directions JSON'
            addressManager?.bestRoute(currentLocation: currentLocation, nodeLocations: addresses)
            
            self.delayExecution(10)

            println("Loading routes:")
            for address : FRLocation in addresses {
                println("Address Text: \(address.addressText!)")
            }
            
            println("Loading waypoints:")
            var count = 0
            if let waypoints = addressManager?.fastRoute {
                count = waypoints.count
                
                for waypoint : FRWayPoint in waypoints {
                    println(waypoint)
                }
            }
            
            XCTAssertTrue(count > 0, "Successfully retrieved waypoints from disk")
        }
        
        AddressManager.showCacheURL()
    }
    
    func testPolyLine() {
        var startLocation = FRLocation(latitude: 37.3639071, longtitude: -122.0415355, placemark: nil, addressText: nil)
        var endLocation = FRLocation(latitude: 37.3700054, longtitude: -122.0409289, placemark: nil, addressText: nil)
        
    
        var polyLine = "ms`cFrf{gVgN?gA?{BBE?gB?O?I?GAKAMCOCA?k@MmAY}@U}@SeB_@"
        var polyLinePath = GMSPath(fromEncodedPath: polyLine)
        var count = polyLinePath.count()
        println("Count = \(count)")
        
        var startLocationMatrix = CLLocationCoordinate2D(latitude: startLocation.latitude, longitude: startLocation.longtitude)
        println("Starting Latitude: \(startLocationMatrix.latitude), Longtitude: \(startLocationMatrix.longitude)")
        
        for p in 1...count {
            var point = polyLinePath.coordinateAtIndex(p) as CLLocationCoordinate2D
            println("Midpoint - Latitude: \(point.latitude), Longtitude: \(point.longitude)")
        }
        
        
        var endLocationMatrix = CLLocationCoordinate2D(latitude: endLocation.latitude, longitude: endLocation.longtitude)
        println("ENding Latitude: \(endLocationMatrix.latitude), Longtitude: \(endLocationMatrix.longitude)")
    }
    
}