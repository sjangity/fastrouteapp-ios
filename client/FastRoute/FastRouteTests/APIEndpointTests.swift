//
//  APIEndpointTests.swift
//  FastRoute
//
//  Created by apple on 8/24/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import XCTest

class APIEndpointTests: BaseViewControllerTests {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.        
        
        var communicator = TCServiceCommunicator.sharedCommunicator()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGoogleGeocode() {
//https://maps.googleapis.com/maps/api/geocode/json?address=861%2520Hollenbeck%2520Avenue%2C%2520Sunnyvale%2C%2520CA%252094087&key=AIzaSyApTr_LvWVO3ltwvlEMHHZNuofscsSUURc

//https://maps.googleapis.com/maps/api/geocode/json?address=861+Hollenbeck+Avenue%2C+Sunnyvale%2C+CA+94087&key=AIzaSyApTr_LvWVO3ltwvlEMHHZNuofscsSUURc
    
        var address = "1842 N Shoreline Blvd, Mountain View, CA 94043"
        
        networkClient?.getGeocode(address, entityName: "Address")
    
        self.delayExecution(4.5)
        
        var jsonDict = networkClient?.communicator?.getJSONFromDiskWithClassName("Address")
        println(jsonDict!)
        
        XCTAssertNotNil(jsonDict, "Able to read back written JSON file")
    }

}
