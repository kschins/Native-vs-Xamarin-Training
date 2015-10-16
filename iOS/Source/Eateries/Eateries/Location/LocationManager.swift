//
//  LocationManager.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/7/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationAccessStatus {
    case Success
    case Denied
    case Undetermined
    case Disabled
}

class LocationManager : NSObject, CLLocationManagerDelegate {
    typealias LocationCallback = (CLLocation) -> ()
    
    let theLocationManager = CLLocationManager()
    let locationUpdateCallback: LocationCallback
    var userCurrentLocation: CLLocation?
    
    init(callback: LocationCallback) {
        self.locationUpdateCallback = callback

        super.init()
        self.theLocationManager.delegate = self
        self.theLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // determine if we have access to the user's location
    class func accessToUserLocation() -> LocationAccessStatus {
        if CLLocationManager.locationServicesEnabled() == false {
            // this device does not support location services
            return LocationAccessStatus.Disabled
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .Denied, .Restricted:
                return LocationAccessStatus.Denied
            case .NotDetermined:
                return LocationAccessStatus.Undetermined
            default:
                return LocationAccessStatus.Success
            }
        }
    }
    
    func getUsersCurrentLocation() {
        let status = LocationManager.accessToUserLocation()
        
        if status == .Success {
            theLocationManager.startUpdatingLocation()
        } else if status == .Undetermined {
            theLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            self.getUsersCurrentLocation()
        } else if status == .Denied || status == .Restricted {
            theLocationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostRecentLocation = locations.last! as CLLocation
        userCurrentLocation = mostRecentLocation
        
        // stop updating
        manager.stopUpdatingLocation()
        
        // callback
        locationUpdateCallback(userCurrentLocation!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // stop updating
        manager.stopUpdatingLocation()
        print("Failed to find location " + error.description)
        
        // callback with no location
        //locationUpdateCallback(nil)
    }
}
