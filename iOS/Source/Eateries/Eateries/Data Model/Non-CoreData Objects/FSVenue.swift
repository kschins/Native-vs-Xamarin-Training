//
//  FSVenue.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation

class FSVenue {
    var name : String?
    var website : String?
    var address : String?
    var city : String?
    var state : String?
    var postalCode : String?
    var latitude : Double?
    var longitude : Double?
    var telephone : String?
    var twitter : String?
    
    init(venue : [String : AnyObject]) {
        // name
        if let venueName = venue["name"] as? String {
            self.name = venueName
        }
        
        // website
        if let url = venue["url"] as? String {
            self.website = url
        }
        
        // contact
        if let contact = venue["contact"] as? [String : AnyObject]
        {
            if let phone = contact["formattedPhone"] as? String
            {
                self.telephone = phone
            }
            if let handle = contact["twitter"] as? String
            {
                self.twitter = handle
            }
        }
        
        // location
        if let location = venue["location"] as? [String : AnyObject],
        venueAddress = location["address"] as? String,
        venueCity = location["city"] as? String,
        venueState = location["state"] as? String,
        venuePostalCode = location["postalCode"] as? String,
        lat = location["lat"] as? Double,
        lng = location["lng"] as? Double
        {
            self.address = venueAddress
            self.city = venueCity
            self.state = venueState
            self.postalCode = venuePostalCode
            self.latitude = lat
            self.longitude = lng
        }
    }
}