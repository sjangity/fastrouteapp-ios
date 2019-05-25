//
//  AppDelegateTests.swift
//  FastRoute
//
//  Created by apple on 8/24/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import XCTest
import FastRoute

class AppDelegateTests: BaseViewControllerTests {

//    var appDelegate: AppDelegate!
    var didFinishLaunchingWithOptionsReturn: Bool!

    override func setUp() {
        super.setUp()
        
        // test framewrok code
//        appDelegate = AppDelegate()
        let someDelegate = UIApplication.sharedApplication().delegate
        var appDelegate =  someDelegate as? AppDelegate //EXC_BAD_ACCESS here

        didFinishLaunchingWithOptionsReturn = appDelegate!.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)

    }
   
    override func tearDown() {
        super.tearDown()
        
        // test framework code
    }
    
    func testDidFinishLaunchingReturnsYES() {
        // uses swifts coalescing operator - if bool not nil unwraps bool and uses it otherwise expression evaluate to false
//        XCTAssertTrue(didFinishLaunchingWithOptionsReturn ?? false, "Delegate pass")

        XCTAssertTrue(didFinishLaunchingWithOptionsReturn != nil && didFinishLaunchingWithOptionsReturn!, "Method should return YES")
    }
    
    func testAPI() {
        var kHost = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
        XCTAssertEqual(kHost, "http://127.0.0.1", "Configuration check OK")
        
        var kHostPartial = AppUtil.readValueFromConfigration(Constants.API.kHostPartial) as! String
        XCTAssertEqual(kHostPartial, "127.0.0.1", "Configuration check OK")
    }
}
