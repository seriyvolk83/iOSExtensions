//
//  MapBasedViewController.swift
//  dodo
//
//  Created by Alexander Volkov on 16.12.14.
//  Copyright (c) 2014 seriyvolk83dodo. All rights reserved.
//

import UIKit
import MapKit

class MapBasedViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    var locationManager = CLLocationManager()
    var targetRegion: MKCoordinateRegion?
    var targetPlacemark: MKPlacemark?
    var targetAddress: String?
    var isAppear: Bool = false
    
    var lastOpenedAnnotation: ObjectLocation?
    var lastOpenedPinAnnotationView: PinAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isAppear = true
        
        let userLocation = mapView.userLocation
        
        // If there is target location, then show it, else show user's location at the center of the map
        if let region = targetRegion {
            zoomToTarget()
        }
        else if let loc = userLocation.location {
            // Some Houston location for example. Should be replaced with the center of area there we have location markerss
            let coord = HoustonMap.houstonCenterLocation()
            // Commented to show current user's position
            //        zoomToLocation(coord)               // Zoom to some point in Houston
            
            /// Move to user's location
            let region = MKCoordinateRegionMakeWithDistance (loc.coordinate, 20000, 20000)
            mapView.setRegion(region, animated: false)
        }
    }
    

    func syncCalendarButtonWithEvent(hasEvent: Bool) {
        if hasEvent {
            addToCalendarButton.setTitle("Remove From Calendar".uppercaseString, forState: UIControlState.Normal)
            addToCalendarButton.setImage(nil, forState: UIControlState.Normal)
        }
        else {
            addToCalendarButton.setTitle("Add To Calendar".uppercaseString, forState: UIControlState.Normal)
            addToCalendarButton.setImage(UIImage(named:"iconAddCalendarWhite"), forState: UIControlState.Normal)
        }
        placeButtonIconOnRight(addToCalendarButton)
    }
    /**
    Fills targetRegion and targetPlacemark and invokes zoomToTarget()
    */
    func tryDefineLocationByAddress(address: String) {
        let location: NSString = address
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location as String, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if placemarks != nil {
                if  placemarks.count > 0 {
                    self.targetAddress = address
                    let topResult: CLPlacemark = placemarks[0] as! CLPlacemark;
                    let placemark: MKPlacemark = MKPlacemark(placemark: topResult);
                    
                    var region = MKCoordinateRegionMakeWithDistance(HoustonMap.houstonCenterLocation(), 20000, 20000)
                    region.center = (placemark.region as! CLCircularRegion).center;
                    region.span.longitudeDelta /= 8.0;
                    region.span.latitudeDelta /= 8.0;
                    
                    self.targetRegion = region
                    self.targetPlacemark = placemark
                    if self.isAppear {
                        self.zoomToTarget()
                    }
                }
            }
        })
    }
    
    func zoomToTarget() {
        if let mark = self.targetPlacemark {
            // Change visible region on the map
            self.mapView.setRegion(self.targetRegion!, animated: false)
            
            // Add annotation
            let info = createLocationInfoObjectFromCurrentObject()
            let o = ObjectLocation(object: info, coord: mark.coordinate)
            o.address = targetAddress
            if let currentAnnotation = lastOpenedAnnotation {
                self.mapView.removeAnnotation(currentAnnotation)
            }
            self.mapView.addAnnotation(o)
            self.lastOpenedAnnotation = o
        }
    }
    
    // Should be overrided by subclass
    func getNameForMapCallout() -> String {
        return "<NONAME>"
    }
    
    func createLocationInfoObjectFromCurrentObject() -> LocalInfoObject {
        var name = getNameForMapCallout()
        var info = LocalInfoObject(id: "0", name: name)
        info.address = targetAddress
        info.coordinate = targetPlacemark?.coordinate
        return info
    }
    
    // Optional method. Can be used if logistic location is not defined.
    func zoomToLocation(coord:CLLocationCoordinate2D) {
        
        let METERS_PER_MILE:Double = 1609.344
        let radiusInMiles:Double = 20.0
        let viewRegion = MKCoordinateRegionMakeWithDistance(coord, radiusInMiles*METERS_PER_MILE, radiusInMiles*METERS_PER_MILE);
        mapView.setRegion(viewRegion, animated: true)
    }
    //// MARK: mapView delegate
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println("LogisticsViewController: mapView:didUpdateUserLocation: \(userLocation.location.coordinate)")
        if targetRegion == nil {
            mapView.centerCoordinate = userLocation.location.coordinate
        }
        else {
            lastOpenedPinAnnotationView?.updateData()
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        if let o = annotation as? ObjectLocation {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("ObjectLocation")
            if view == nil {
                let pin = PinAnnotationView(annotation: o, reuseIdentifier: "ObjectLocation")
                pin.needRightArrow = false
                pin.enabled = true
                pin.object = o.object
                
                pin.mapView = self.mapView
                pin.canShowCallout = false
                pin.image = UIImage(named: "iconPin")
                self.lastOpenedPinAnnotationView = pin
                view = pin
            }
            else {
                view.annotation = annotation
            }
            return view
        }
        return nil
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // locations are updated
    }
    
    /// Calendar support
    
    @IBAction func addToCalendarAction(sender: AnyObject) {
        if let e = getCalendarEvent() {
            let helper = CalendarHelper.sharedInstance
            if helper.hasEventInCalendar(e) {
                helper.removeFromCalendar(e, callback: { (removed:Bool) -> () in
                    if removed {
                        self.syncCalendarButtonWithEvent(false)
                    }
                })
            }
            else {
                helper.addToCalendar(e, callback: { (added:Bool) -> () in
                    if added {
                        self.syncCalendarButtonWithEvent(true)
                    }
                })
            }
        }
    }
    
    func getCalendarEvent() -> CalendarEvent? {
        return nil
    }
}
