//
//  RouteSubDetailsViewController.swift
//  FastRoute
//
//  Created by apple on 9/3/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

protocol RouteSubDetailsViewControllerDelegate {
    func previousPageRequested(fromIndex: Int)
    func nextPageRequested(fromIndex: Int)
}

class RouteSubDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var wayPointTextField: UITextField!
    @IBOutlet weak var wayPointText: UILabel!
    @IBOutlet weak var wayPointDirectionsTableView: UITableView!
    
    @IBOutlet weak var wayPointLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var wayPointMapView: UIView!


    var mapView: GMSMapView!
    var delegate: RouteSubDetailsViewControllerDelegate?
    
    var pageText: String? {
        didSet {
            updateUI()
        }
    }
    var waypoint: FRWayPoint! {
        didSet {
            updateUI()
        }
    }
    var pageIndex : Int!
    var pageTotal: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DLog("RouteSubDetailsViewController.viewDidLoad")
        
        initializeWayPointForDisplay()
        
        updateUI()
        
        wayPointDirectionsTableView.dataSource = self
        wayPointDirectionsTableView.delegate = self
        wayPointDirectionsTableView.tableFooterView = UIView(frame: CGRectZero)
        
        drawMap()
        
//        self.navigationItem.title = "test"
        
        var rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("dismissView:"))
        
        var navigationController = self.navigationController
//        self.navigationController?.navigationItem.rightBarButtonItem = rightButton
//        navigationItem.rightBarButtonItem = rightButton

        if pageIndex <= 0 {
            previousButton.hidden = true
            nextButton.styledGreen()
        } else if pageIndex >= pageTotal-1 {
            nextButton.hidden = true
            previousButton.styledGreen()
        } else {
            previousButton.hidden=false
            nextButton.hidden=false
            previousButton.styledGreen()
            nextButton.styledGreen()
        }

        previousButton.addTarget(self, action: Selector("previousPageRequested:"), forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.addTarget(self, action: Selector("nextPageRequested:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func previousPageRequested(sender: AnyObject) {
        delegate?.previousPageRequested(pageIndex)
    }
    
    func nextPageRequested(sender: AnyObject) {
        delegate?.nextPageRequested(pageIndex)
    }
    
    func dismissView(sender: AnyObject) {
//        dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func latRad(degrees: CLLocationDegrees) -> Double {
        var sinVal = sin(AppUtil.DegreesToRadians(degrees))
        var radX2 = (log(1+sinVal) / (1 - sinVal)) / 2
        return max(min(radX2,M_PI), -M_PI) / 2
    }
    
    func zoom(mapx: Int, worldpx: Int, fraction: Double) -> Double {
        return floor(log(Double(mapx) / Double(worldpx) / fraction) / M_LN2 )
    }
    
    func getBoundsZoomLevel(bounds: GMSCoordinateBounds) -> Float {
        // http://stackoverflow.com/questions/6048975/google-maps-v3-how-to-calculate-the-zoom-level-for-a-given-bounds
        var ZOOM_MAX = 21.0
        
        var ne = bounds.northEast
        var sw = bounds.southWest
        
        var latFraction = ( latRad(ne.latitude)-latRad(sw.latitude) ) / M_PI
        var lngDiff = ne.longitude - sw.longitude
        var lngFraction = ( (lngDiff < 0) ? (lngDiff + 360) : (lngDiff) / 360)
        var latZoom = zoom(Int(mapView.bounds.height),worldpx: 256,fraction: latFraction)
        var lngZoom = zoom(Int(mapView.bounds.width),worldpx: 256,fraction: lngFraction)
        
        var minVal = min(latZoom,lngZoom)
        minVal = min(minVal,ZOOM_MAX)
        return Float(minVal)
    }
    
    func drawMap() {
        //var mapView = GMSMapView.mapWithFrame(wayPointMapView.bounds, camera: RouteSubDetailsViewController.defaultCamera())
        mapView = GMSMapView(frame: wayPointMapView.bounds)
        mapView.autoresizingMask = UIViewAutoresizing.FlexibleWidth |
                              UIViewAutoresizing.FlexibleHeight |
                              UIViewAutoresizing.FlexibleBottomMargin;

        mapView.settings.zoomGestures = true
//        mapView.settings.myLocationButton = true
//        mapView.myLocationEnabled = true;
//        mapView.padding = UIEdgeInsetsMake(0, 0, 140.0, 0);
//        mapView.settings.compassButton = true
        
        var path = GMSMutablePath()
        var steps = waypoint.steps
        
        var cameraSet = false
        
        var stepCount = 0
        
        for step : FRWayPointStep in steps {
            var start_location = step.startAddress
            var end_location = step.endAddress
            
            // add start point
            var startLocationMatrix = CLLocationCoordinate2D(latitude: start_location.latitude, longitude: start_location.longtitude)
//            DLog("Starting Latitude: \(startLocationMatrix.latitude), Longtitude: \(startLocationMatrix.longitude)")

            if stepCount == 0 {
                var marker = GMSMarker(position: startLocationMatrix)
                marker.icon = UIImage(named: "gms-marker-icon-start.png")
                marker.title = "Start"
                marker.map = mapView
            }
            path.addCoordinate(startLocationMatrix)

            // add intermediate polylines
            var polyLinePath = GMSPath(fromEncodedPath: step.polyline)
//            DLog("Count = \(polyLinePath.count())")
            var maxPoints = 0
            for p in 1...polyLinePath.count() {
                var coord = polyLinePath.coordinateAtIndex(p)
                if coord.latitude != -180.0 {
                    path.addCoordinate(coord)
//                    DLog("Midpoint - Latitude: \(coord.latitude), Longtitude: \(coord.longitude)")
                }
            }
            
            // and end point
            var endLocationMatrix = CLLocationCoordinate2D(latitude: end_location.latitude, longitude: end_location.longtitude)
//            DLog("ENding Latitude: \(endLocationMatrix.latitude), Longtitude: \(endLocationMatrix.longitude)")
            
            if stepCount == steps.count-1 {
                var marker = GMSMarker(position: endLocationMatrix)
                marker.icon = UIImage(named: "gms-marker-icon-end.png")
                marker.title = "End"
                marker.map = mapView
            }
            path.addCoordinate(endLocationMatrix)
            
            if !cameraSet {

//                // Choose the midpoint of the coordinate to focus the camera on.
//                var mid = GMSGeometryInterpolate(startLocationMatrix, endLocationMatrix, 0.5);
//                var camera = GMSCameraPosition(target: mid, zoom: 12, bearing: 0, viewingAngle: 45)
//                mapView.camera = camera

//                // compute bounds
                var startPoint = CLLocationCoordinate2D(latitude: waypoint.startAddress.latitude, longitude: waypoint.startAddress.longtitude)
                var endPoint = CLLocationCoordinate2D(latitude: waypoint.endAddress.latitude, longitude: waypoint.endAddress.longtitude)
                var bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: startPoint, coordinate: endPoint)
                var zoomLevel = getBoundsZoomLevel(bounds)
                DLog("Optimal zoom level = \(zoomLevel)")
//                var cameraUpdate = GMSCameraUpdate.fitBounds(bounds)
//                mapView.moveCamera(cameraUpdate)
//
//                var newPosition = GMSCameraPosition.cameraWithLatitude(start_location.latitude, longitude: start_location.longtitude, zoom: zoomLevel)
//                mapView.camera = newPosition
//                // Choose the midpoint of the coordinate to focus the camera on.
                var mid = GMSGeometryInterpolate(startPoint, endPoint, 0.5);
                var camera = GMSCameraPosition(target: mid, zoom: zoomLevel, bearing: 0, viewingAngle: 45)
                mapView.camera = camera
                cameraSet = true
            }
            stepCount += 1
        }
        
        var polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.redColor()
        polyline.strokeWidth = 5
        polyline.geodesic = true
        
        polyline.map = mapView

        wayPointMapView.addSubview(mapView)
    }
    
    func updateUI() {
        // If you try to trigger UI update code before the ViewController's view is loaded,
        //  your app will crash. The weightTextField and other UI outlets that are connected
        //  are not initialized until the view is setup.
        //  That means your app will crash if you don't use optional chaining (i.e.: weightTextField?.text)
        
        // With optional chaining, if the value is not set, nothing will happen. The UI isn't created, so it
        //  can be updated, and the app won't crash, which is great for you!
        if let pageText = pageText {
            wayPointText?.text = "\(pageText)"
        }
    }

    class func defaultCamera() -> GMSCameraPosition {
        return GMSCameraPosition.cameraWithLatitude(37.358699, longitude: -122.031848, zoom: 6)
    }
    
    func initializeWayPointForDisplay() {
        if let waypoint = waypoint {
            wayPointLabel.text = waypoint.endAddress.addressText
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: GMS delegate

    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
    }
    
    
    // MARK: Table view data source / delegate methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        var cell = tableView.dequeueReusableCellWithIdentifier("kDirectionsListTableView") as? DirectionsTableViewCell
        
        if cell == nil {
            cell = DirectionsTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "kDirectionsListTableView")
        }
        
        var row = indexPath.row
        var step = waypoint.steps[row]
        
        //cell.textLabel?.text = step.text
//        var attributedString = NSMutableAttributedString(string: step.text, attributes: [
//                NSFontAttributeName : UIFont.systemFontOfSize(14)
//        ])
        
//        cell.textLabel?.attributedText =  attributedString
//        cell.detailTextLabel?.attributedText=NSMutableAttributedString(string: step.distanceInMiles, attributes: [
//                NSForegroundColorAttributeName : UIColor(rgb: 0x5A8FB2)
//        ])
        
        
        cell?.directionsDistance.attributedText = NSMutableAttributedString(string: step.distanceInMiles, attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(14)
        ])

        cell?.directionsText.attributedText=NSMutableAttributedString(string: step.text, attributes: [
                NSForegroundColorAttributeName : UIColor(rgb: 0x5A8FB2),
                NSFontAttributeName : UIFont.systemFontOfSize(17)
        ])

        
        

        
//          [[NSAttributedString alloc] initWithString:[owner valueForKey:@"username"]
//        attributes:@{
//            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
//            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
//        }];

        
        return cell!
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoint.steps.count
    }
}