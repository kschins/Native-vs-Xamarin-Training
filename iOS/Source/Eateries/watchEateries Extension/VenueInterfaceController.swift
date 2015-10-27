//
//  VenueInterfaceController.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import WatchKit
import CoreLocation

class VenueInterfaceController: WKInterfaceController {
    var venue: FSVenue!
    
    // outlets
    @IBOutlet weak var venueNameLabel: WKInterfaceLabel!
    @IBOutlet weak var venuePhoneLabel: WKInterfaceLabel!
    @IBOutlet weak var venueWebsiteLabel: WKInterfaceLabel!
    @IBOutlet weak var venueAddressLabel: WKInterfaceLabel!
    @IBOutlet weak var venueMap: WKInterfaceMap!
    @IBOutlet weak var zoomSlider: WKInterfaceSlider!
    
    // vars
    var coordinates: CLLocationCoordinate2D!
    
    // constants
    let radius: CLLocationDistance = 100
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let venue = context as? FSVenue {
            self.venue = venue
            setTitle(venue.name)
            
            // set labels
            venueNameLabel.setText(venue.name)
            venuePhoneLabel.setText(venue.telephone)
            venueWebsiteLabel.setText(venue.website)
            venueAddressLabel.setText(venue.displayAddress())
            
            // set map location/region
            if let lat = venue.latitude, long = venue.longitude {
                coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, radius, radius)
                venueMap.setRegion(coordinateRegion)
                venueMap.addAnnotation(coordinates, withPinColor: .Red)
            } else {
                venueMap.setHidden(true)
            }
            
            // always hide for now
            zoomSlider.setHidden(true)
        }
    }
    
    @IBAction func changeMapRegion(value : Float) {
        let degrees: CLLocationDegrees = CLLocationDegrees(value) / 10
        let span = MKCoordinateSpanMake(degrees, degrees)
        let region = MKCoordinateRegionMake(coordinates, span)
        venueMap.setRegion(region)
    }
}