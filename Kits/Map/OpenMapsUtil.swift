//
//  OpenMapsUtil.swift
//  dodo
//
//  Created by TCASSEMBLER on 03.12.15.
//  Copyright © 2015 seriyvolk83dodo. All rights reserved.
//

import Foundation
import MapKit
import Contacts

/**
 * Utility that helps to open Maps app
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
class OpenMapsUtil {
    
    /// the singleton
    class var sharedInstance: OpenMapsUtil {
        struct Singleton { static let instance = OpenMapsUtil() }
        return Singleton.instance
    }
    
    /**
     Handles the open map event
     
     - parameter notification: the notification
     */
    func handleOpenMap(notification: NSNotification) {
        let location = notification.userInfo!["location"] as! [Double]
        let mapUrl = "http://maps.apple.com/?ll=\(location[0]),\(location[1])&q=test"
        UIApplication.sharedApplication().openURL(NSURL(string: mapUrl)!)
    }
    
    func openAddress(address: String) {
        var addressToLinkTo = "http://maps.apple.com/?q=\(address)"
        
        addressToLinkTo = addressToLinkTo.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url = NSURL(string: addressToLinkTo)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    /**
     Open given coordinate in Map app
     
     - parameter coordinate:    the coordinate
     - parameter addressStreet: the street address
     */
    func openMapWithCoordinate(coordinate: CLLocationCoordinate2D, addressStreet: String?) {
        if isAppInForeground() {
            let location = MKPlacemark(coordinate: coordinate,
                addressDictionary: addressStreet != nil ? [CNPostalAddressStreetKey: addressStreet!] : nil)
            let item = MKMapItem(placemark: location)
            item.openInMapsWithLaunchOptions(nil)
        }
        else {
            needToOpenLocationWhenAppBecomeActive = (coordinate: coordinate, addressStreet: addressStreet)
        }
    }

}
