//
//  GMSTests.swift
//  FastRoute
//
//  Created by apple on 8/27/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import XCTest

class GMSTests: BaseViewControllerTests {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGoogleAutocomplete() {
        networkClient?.placeAutoComplete("1842 N Shoreline Blvd, Mountain View, CA 94043")
        
        self.delayExecution(4.5)
    }

}
