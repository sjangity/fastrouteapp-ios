//
//  NetworkClient.swift
//  FastRoute
//
//  Created by apple on 8/24/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class NetworkClient: NSObject {

    var communicator: TCServiceCommunicator?
    var placesClient: GMSPlacesClient?
    
    static let sharedClient: NetworkClient = NetworkClient()
    
    override init() {
        DLog("NetworkClient.init")
               communicator = TCServiceCommunicator.sharedCommunicator()
        
        super.init()
    }
    
    // MARK: Fastroute backend API calls
    
    func getAutocompleteGeocode(address: String, entityName: String) {
        // make network request
        
        // save response data to file
        
        var escapedAddress = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
        var host = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
        var endPoint = "/google/geocode?address=\(escapedAddress!)"
        
        var operations = NSMutableArray()
        var networkOperation = communicator?.GET(endPoint,
            success: {(operation: TCServiceCommunicatorOperation!, response: AnyObject!) -> Void in
            
            // write JSON dictionary to disk
            self.communicator?.saveJSONResponseToDisk(response, withEntityName: entityName)

        }, failure: {(operation: TCServiceCommunicatorOperation!, error: NSError!) -> Void in
            DLog("not worked")
        })
        
        if networkOperation != nil {
            operations.addObject(networkOperation!)
            
            communicator?.enqueueServiceOperations(operations as [AnyObject],
                completionBlock: { ([AnyObject]!) -> Void in
                
                DLog("completion handler")

                // send back notification after latest auto-complete geociding is complete
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.AddressAutocompleteSelectedNotification, object: nil, userInfo: nil)
                
            })
        }
    }
    
    func getDirections(origin: FRLocation, destination: FRLocation, waypoints: String) {
        
            var host = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
            var endPoint = "/google/directions?origin=\(origin.apiDescription)&destination=\(destination.apiDescription)"

            // any waypoints?
            if !waypoints.isEmpty {
                if let escapedWaypoints = waypoints.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                    endPoint += "&waypoints=\(escapedWaypoints)"
                }
            }
        
            var operations = NSMutableArray()
            var networkOperation = communicator?.GET(endPoint,
                success: {(operation: TCServiceCommunicatorOperation!, response: AnyObject!) -> Void in
                
                // write JSON dictionary to disk
                self.communicator?.saveJSONResponseToDisk(response, withEntityName: "Directions")
                
            }, failure: {(operation: TCServiceCommunicatorOperation!, error: NSError!) -> Void in
                DLog("not worked")
            })
            
            if networkOperation != nil {
                operations.addObject(networkOperation!)
                
                communicator?.enqueueServiceOperations(operations as [AnyObject],
                    completionBlock: { ([AnyObject]!) -> Void in
                    
                    DLog("completion handler for directions API")
                    
                    // Notify AddressManager to re-load directions from disk and synch state
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.WayPointDirectionsReceivedNotification, object: nil, userInfo: nil)
                })
            }
//        }
    }
    
    func getDistance(origin: FRLocation, destinations: [FRLocation]) {
        var host = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
        var operations = NSMutableArray()
        
        for destination : FRLocation in destinations {
        
            var endPoint = "/google/distance?origin=\(origin.apiDescription)&destination=\(destination.apiDescription)"
            
            var networkOperation = communicator?.GET(endPoint,
                success: {(operation: TCServiceCommunicatorOperation!, response: AnyObject!) -> Void in

                var jsonErrorOptional: NSError?
                if let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(response as! NSData, options: NSJSONReadingOptions(0), error: &jsonErrorOptional) as? NSDictionary                {

                    if let distance = jsonOptional.valueForKeyPath("result.distance") as? Double {
                        destination.distanceFromOrigin = distance
                    }                
                }
                
            }, failure: {(operation: TCServiceCommunicatorOperation!, error: NSError!) -> Void in
                DLog("not worked")
            })

            if networkOperation != nil {
                operations.addObject(networkOperation!)
            }
        }
            
        if operations.count > 0 {
                
            communicator?.enqueueServiceOperations(operations as [AnyObject],
                completionBlock: { ([AnyObject]!) -> Void in
                
                DLog("completion handler for distance API")

                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.DistanceReceivedNotification, object: nil, userInfo: nil)                    
            })
        }
    }
    
    // get geocode
    func getGeocode(address: String, entityName: String) {
        // make network request
        
        // save response data to file
        
        var escapedAddress = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
        var host = AppUtil.readValueFromConfigration(Constants.API.kHost) as! String
        var endPoint = "/google/geocode?address=\(escapedAddress!)"
        
        var operations = NSMutableArray()
        var networkOperation = communicator?.GET(endPoint,
            success: {(operation: TCServiceCommunicatorOperation!, response: AnyObject!) -> Void in
            
            // write JSON dictionary to disk
            self.communicator?.saveJSONResponseToDisk(response, withEntityName: entityName)
            
//            self.communicator?.checkIfJSONIsArrayOrDictionary(response)
//            var jsonEncodingData = response.dataUsingEncoding(NSUTF8StringEncoding)
//
//            var jsonErrorOptional: NSError?
//            let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(response as! NSData, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
//
//            let jsonDict = jsonOptional as? Dictionary<String, AnyObject>
//            self.communicator?.saveJSONResponseToDisk(jsonDict, withEntityName: "Address")

//            var networkError: NSError? = nil
//            if let responseObjc = NSJSONSerialization.JSONObjectWithData(response as! NSData, options: nil, error: &networkError) as? NSDictionary
//            {
//                DLog("response 2: \(responseObjc)")
//                
//                // save JSON to disk
//                self.communicator?.saveJSONResponseToDisk(responseObjc, withEntityName: "Address")
//            }
        }, failure: {(operation: TCServiceCommunicatorOperation!, error: NSError!) -> Void in
            DLog("not worked")
        })
        
        if networkOperation != nil {
            operations.addObject(networkOperation!)
            
            communicator?.enqueueServiceOperations(operations as [AnyObject],
                completionBlock: { ([AnyObject]!) -> Void in
                
                DLog("completion handler")
            })
        }
    }
    
//    // get directions
//    
//    func getOperation(url: String) -> AnyObject? {
//
//        var result: AnyObject?
//        DLog("endpoint: \(url)")
//        if let url = NSURL(string: url) {
//            DLog("url is ok")
//            let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler:
//            {
//                (data: NSData!, response: NSURLResponse!, error: NSError!) in
//                DLog("got data back")
//                if error != nil {
//                    DLog("Error: \(error.localizedDescription)")
//                } else {
//                    DLog("No error found, let's parse response")
//                    var jsonError: NSError?
//                    if let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
//                        DLog("deserializing JSON")
//                        result = jsonData
////                        DLog(jsonData)
//                        if let resultsArray = jsonData["result"] as? NSArray {
//                            DLog("Results: \(resultsArray)")
//                        }
//                    }
//                }
//                
//            })
//            dataTask.resume()
//        }
//        return result
//    }   


    // MARK: Google API calls from IOS
    
    func placeAutoComplete(address: String) {
        DLog("GMS: autocomplete")
        placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        placesClient?.autocompleteQuery(address, bounds: nil, filter: filter, callback: { (results: [AnyObject]?, error: NSError?) -> Void in
            
            DLog("GMS: Data sent back")
            
            if let error = error {
                DLog("Autocomplete error \(error)")
            } else {
                
                for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        DLog("Result \(result.attributedFullText) with placeID \(result.placeID)")
                    }
                }
                DLog("Done fetching autocomplete results")
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKey.AddressAutocompleteNotification, object: nil, userInfo: ["results":results!])
            }
        })
    }
 
}
