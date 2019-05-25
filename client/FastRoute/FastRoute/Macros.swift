//
//  Macros.swift
//  FastRoute
//
//  Created by apple on 9/21/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import Foundation

// dLog and aLog macros to abbreviate NSLog.
// Use like this:
//
//   dLog("Log this!")
//
#if DEBUG
    func DLog(@autoclosure message:  () -> String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        NSLog("[\(filename.lastPathComponent):\(line)] \(function) - %@", message())
    }
#else
    func DLog(@autoclosure message:  () -> String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    }
#endif

func aLog(message: String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    NSLog("[\(filename.lastPathComponent):\(line)] \(function) - %@", message)
}