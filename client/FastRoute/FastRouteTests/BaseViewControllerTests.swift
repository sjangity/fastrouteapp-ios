//
//  BaseViewControllerTests.swift
//  FastRoute
//
//  Created by apple on 8/24/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit
import XCTest
import Foundation

extension UIViewController
{
    func viewControllerTests_viewDidAppear(animated: Bool) {
        // http://stackoverflow.com/questions/25368820/is-it-possible-in-swift-to-add-variables-to-an-object-at-runtime
        var parameter = NSNumber(bool: animated)
        objc_setAssociatedObject(self, &Constants.Unit.kViewDidAppearKey, parameter, UInt(OBJC_ASSOCIATION_RETAIN))
    }
}

class BaseViewControllerTests: XCTestCase {

    var realViewDidAppear: Selector!
    var testViewDidAppear: Selector!
    
    var networkClient: NetworkClient?

    override func setUp() {
        super.setUp()
        
        realViewDidAppear = Selector("viewDidAppear")
        testViewDidAppear = Selector("viewControllerTests_viewDidAppear")
        
        // support for google maps
        GMSServices.provideAPIKey(kGMSPlacesAPIKey)
        
        networkClient = NetworkClient()
    }
   
    override func tearDown() {
        super.tearDown()
    }
    
    func swapInstanceMethodsForClass(cls: AnyClass, sel1: Selector, sel2: Selector) {
        // http://stackoverflow.com/questions/24403718/swift-equivalent-objective-c-runtime-class
        var method1 = class_getInstanceMethod(cls, sel1)
        var method2 = class_getInstanceMethod(cls, sel2)
        method_exchangeImplementations(method1, method2)
    }
    
    func delayExecution(interval: NSTimeInterval) {
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: interval))
    }

}
