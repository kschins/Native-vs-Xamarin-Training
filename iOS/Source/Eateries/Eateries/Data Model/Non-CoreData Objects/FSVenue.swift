//
//  FSVenue.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class FSVenue {
    let venueID : String
    let name : String
    let mainVenueCollectionName : String
    var website : String?
    var telephone : String?
    var twitter : String?
    let favorite : Bool
    
    // address
    var hasAddress = true
    var address : String?
    var city : String?
    var state : String?
    var country : String?
    var postalCode : String?
    var latitude : Double?
    var longitude : Double?
    
    // valid venue
    var validVenue = true
    
    init(venue : [String : AnyObject]) {
        // id
        self.venueID = venue["id"] as! String
        
        // name
        self.name = venue["name"] as! String
    
        // main venue collection name
        self.mainVenueCollectionName = ""
        
        // website
        if let url = venue["url"] as? String {
            self.website = url
        }
        
        // favorite
        self.favorite = false
        
        // contact
        if let contact = venue["contact"] as? [String : AnyObject]
        {
            if let phone = contact["formattedPhone"] as? String
            {
                self.telephone = phone
            } else {
                validVenue = false
            }
            
            if let handle = contact["twitter"] as? String
            {
                self.twitter = handle
            }
        } else {
            //validVenue = false
        }
        
        // location
        if let location = venue["location"] as? [String : AnyObject],
        venueAddress = location["address"] as? String,
        venueCity = location["city"] as? String,
        venueState = location["state"] as? String,
        venuePostalCode = location["postalCode"] as? String,
        venueCountry = location["country"] as? String,
        lat = location["lat"] as? Double,
        lng = location["lng"] as? Double
        {
            self.address = venueAddress
            self.city = venueCity
            self.state = venueState
            self.country = venueCountry
            self.postalCode = venuePostalCode
            self.latitude = lat
            self.longitude = lng
        } else {
            self.hasAddress = false
        }
    }
    
    init(venue: Venue) {
        self.name = venue.name!
        self.venueID = venue.venueID!
        self.telephone = venue.telephone
        self.website = venue.website
        self.twitter = venue.twitter
        self.favorite = venue.favorite!.boolValue
        self.mainVenueCollectionName = venue.mainVenueCollectionName!
        
        // address
        self.address = venue.address!.street
        self.city = venue.address!.city
        self.state = venue.address!.state
        self.country = venue.address!.country
        self.postalCode = venue.address!.postalCode
        self.latitude = venue.address!.latitude!.doubleValue
        self.longitude = venue.address!.longitude!.doubleValue
    }
    
    func createVenue(moc: NSManagedObjectContext) -> Venue {
        let venue = Venue.insertNewObject(moc)
        venue.name = self.name
        venue.venueID = self.venueID
        venue.mainVenueCollectionName = self.mainVenueCollectionName
        
        if let phone = self.telephone {
            venue.telephone = phone
        }
        
        if let handle = self.twitter {
            venue.twitter = handle
        }
        
        if let url = self.website {
            venue.website = url
        }
        
        // favorite
        venue.favorite = NSNumber(bool: self.favorite)
        
        // create address
        let venueAddress = VenueAddress.insertNewObject(moc)
        venueAddress.venue = venue
        
        if hasAddress {
            venueAddress.street = address!
            venueAddress.city = city!
            venueAddress.state = state!
            venueAddress.postalCode = postalCode!
            venueAddress.country = country!
            venueAddress.latitude = NSNumber(double: latitude!)
            venueAddress.longitude = NSNumber(double: longitude!)
        }
        
        return venue
    }
    
    func strippedVenueTelephone() -> String {
        telephone = telephone?.stringByReplacingOccurrencesOfString("(", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString(")", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString(" ", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString("-", withString: "")
        
        return telephone!
    }
    
    func displayAddress() -> String {
        var displayAddress: String = address! + "\n"
        displayAddress += city! + ", " + state! + " " + postalCode!
        
        return displayAddress
    }
}