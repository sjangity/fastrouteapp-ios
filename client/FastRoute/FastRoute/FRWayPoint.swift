//
//  FRWayPoint.swift
//  FastRoute
//
//  Created by apple on 9/2/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import Foundation

class FRWayPointStep: NSObject, NSCoding {
    var distance: Int
    var distanceInMiles: String {
        get {
            var conversion = Double(distance)/1609.34
            if conversion < 0.5 {
                conversion = Double(distance) * 3.28084
                var int_conversion = Int(round(conversion))
                return "\(int_conversion) feet"
            } else {
                let divisor = pow(10.0, Double(2))
                let rounded = round(conversion * divisor) / divisor
                return "\(rounded) miles"
            }
        }
    }
    var duration: Int
    var text: String
    var polyline: String

    var startAddress: FRLocation
    var endAddress: FRLocation
    
    let kWayPointStepDistance = "distance"
    let kWayPointStepDuration = "duration"
    let kWayPointStepText = "text"
    let kWayPointStepPolyline = "polyline"
    let kWayPointStartAddress = "startAddress"
    let kWayPointEndAddress = "endAddress"
    
    init(startAddress: FRLocation, endAddress: FRLocation, distance: Int, duration: Int, text: String, polyline: String) {
        self.distance = distance
        self.duration = duration
        self.text = text
        self.polyline = polyline
        
        self.startAddress = startAddress
        self.endAddress = endAddress
        
        super.init()
    }
    
    override var description: String {
        return "Step: Start: \(startAddress), End: \(endAddress), Distance: \(distance)"
    }
    
    // NSCoder Protocol methods
    
    required init(coder aDecoder: NSCoder) {
        self.distance = aDecoder.decodeObjectForKey(kWayPointStepDistance) as! Int
        self.duration = aDecoder.decodeObjectForKey(kWayPointStepDuration) as! Int
        self.text = aDecoder.decodeObjectForKey(kWayPointStepText) as! String
        self.polyline = aDecoder.decodeObjectForKey(kWayPointStepPolyline) as! String
        
        self.startAddress = aDecoder.decodeObjectForKey(kWayPointStartAddress) as! FRLocation
        self.endAddress = aDecoder.decodeObjectForKey(kWayPointEndAddress) as! FRLocation
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(distance, forKey: kWayPointStepDistance)
        aCoder.encodeObject(duration, forKey: kWayPointStepDuration)
        aCoder.encodeObject(text, forKey: kWayPointStepText)
        aCoder.encodeObject(polyline, forKey: kWayPointStepPolyline)

        aCoder.encodeObject(startAddress, forKey: kWayPointStartAddress)
        aCoder.encodeObject(endAddress, forKey: kWayPointEndAddress)
    }
}

class FRWayPoint: NSObject, NSCoding {

//    var startAddress: String
//    var endAddress: String
    var startAddress: FRLocation
    var endAddress: FRLocation
    var distance: Int
    var duration: Int
    var steps: [FRWayPointStep]
    var distanceInMiles: String? {
        get {
            var conversion = Double(distance)/1609.34
            if conversion < 0.5 {
                conversion = Double(distance) * 3.28084
                var int_conversion = Int(round(conversion))
                return "\(int_conversion) feet"
            } else {
                let divisor = pow(10.0, Double(2))
                let rounded = round(conversion * divisor) / divisor
                return "\(rounded) miles"
            }
        }
    }
    let kWayPointStartAddress = "startAddress"
    let kWayPointEndAddress = "endAddress"
    let kWayPointDistance = "distance"
    let kWayPointDuration = "duration"
    let kWayPointSteps = "steps"
    
    init(startAddress: FRLocation, endAddress: FRLocation, distance: Int, duration: Int) {
        self.startAddress = startAddress
        self.endAddress = endAddress
        self.distance = distance
        self.duration = duration
        
        self.steps = [FRWayPointStep]()
        
        super.init()
    }
    
    override var description: String {
        return "Waypoint Start: \(startAddress), End: \(endAddress), Distance: \(distance)"
    }
    
    func addStep(startAddress: FRLocation, endAddress: FRLocation, distance: Int, duration: Int, text: String, polyline: String) {
        var step = FRWayPointStep(startAddress: startAddress, endAddress: endAddress,distance: distance, duration: duration, text: text, polyline: polyline)
        steps.append(step)
    }

    // NSCoder Protocol methods
    
    required init(coder aDecoder: NSCoder) {
        self.startAddress = aDecoder.decodeObjectForKey(kWayPointStartAddress) as! FRLocation
        self.endAddress = aDecoder.decodeObjectForKey(kWayPointEndAddress) as! FRLocation
        self.distance = aDecoder.decodeObjectForKey(kWayPointDistance) as! Int
        self.duration = aDecoder.decodeObjectForKey(kWayPointDuration) as! Int
        
        self.steps = aDecoder.decodeObjectForKey(kWayPointSteps) as! [FRWayPointStep]
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(startAddress, forKey: kWayPointStartAddress)
        aCoder.encodeObject(endAddress, forKey: kWayPointEndAddress)
        aCoder.encodeObject(distance, forKey: kWayPointDistance)
        aCoder.encodeObject(duration, forKey: kWayPointDuration)
        aCoder.encodeObject(steps, forKey: kWayPointSteps)
    }

}