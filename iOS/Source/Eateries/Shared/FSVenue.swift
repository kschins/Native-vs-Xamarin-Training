//
//  FSVenue.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FSVenue {
    var venueID : String!
    var name : String!
    var mainVenueCollectionName : String!
    var website : String?
    var telephone : String?
    var twitter : String?
    var price : String?
    var favorite : Bool!
    
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
    
    init() {
        self.venueID = ""
        self.name = ""
        self.mainVenueCollectionName = ""
        self.website = ""
        self.telephone = ""
        self.twitter = ""
        self.price = ""
        self.favorite = false
    }
    
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
        
        // price
        self.price = "$"
        if let attributes = venue["attributes"] as? [String : AnyObject] {            
            if let groups = attributes["groups"] as? [AnyObject] {
                for item in groups {
                    if let name = item["name"] as? String {
                        if name == "Price" {
                            self.price = item["summary"] as? String
                        }
                    }
                }
            }
        }
        
        // favorite
        self.favorite = false
        
        // contact
        if let contact = venue["contact"] as? [String : AnyObject] {
            if let phone = contact["formattedPhone"] as? String {
                self.telephone = phone
            } else {
                validVenue = false
            }
            
            if let handle = contact["twitter"] as? String {
                self.twitter = handle
            }
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
        self.price = venue.price
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
        
        if let price = self.price {
            venue.price = price
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
    
    func venueFromDictionary(dictionary: [String : AnyObject]) {
        self.name = dictionary["name"] as? String
        self.venueID = dictionary["venueID"] as? String
        self.telephone = dictionary["telephone"] as? String
        self.website = dictionary["website"] as? String
        self.twitter = dictionary["twitter"] as? String
        self.price = dictionary["price"] as? String
        self.favorite = dictionary["favorite"] as? Bool
        self.mainVenueCollectionName = dictionary["mainVenueCollectionName"] as? String
        
        // address
        if let address = dictionary["address"] as? [String : AnyObject] {
            self.address = address["street"] as? String
            self.city = address["city"] as? String
            self.state = address["state"] as? String
            self.country = address["country"] as? String
            self.postalCode = address["postalCode"] as? String
            self.latitude = address["latitude"] as? Double
            self.longitude = address["longitude"] as? Double
        } else {
            self.address = ""
            self.city = ""
            self.state = ""
            self.country = ""
            self.postalCode = ""
            self.latitude = 0.0
            self.longitude = 0.0
        }
    }
    
    func strippedVenueTelephone() -> String {
        telephone = telephone?.stringByReplacingOccurrencesOfString("(", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString(")", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString(" ", withString: "")
        telephone = telephone?.stringByReplacingOccurrencesOfString("-", withString: "")
        
        return telephone!
    }
    
    func displayAddress() -> String {
        if let street = address {
            var displayAddress: String = street + "\n"
            
            if let theCity = city, theState = state, theZip = postalCode {
                displayAddress += theCity + ", " + theState + " " + theZip
            }
            
            return displayAddress
        } else {
            return ""
        }
    }
    
    func displayPrice() -> NSAttributedString {
        let greyDollarSignAttribute = [NSForegroundColorAttributeName: UIColor.lightGrayColor()]
        let greyDollarSignString = NSMutableAttributedString(string: "$", attributes: greyDollarSignAttribute)
        let attributedPriceString = NSMutableAttributedString(string: price!)
        
        if price?.characters.count == 0 {
            return NSAttributedString(string: "N/A")
        } else if price?.characters.count == 1 {
            attributedPriceString.appendAttributedString(greyDollarSignString)
            attributedPriceString.appendAttributedString(greyDollarSignString)
            attributedPriceString.appendAttributedString(greyDollarSignString)
        } else if price?.characters.count == 2 {
            attributedPriceString.appendAttributedString(greyDollarSignString)
            attributedPriceString.appendAttributedString(greyDollarSignString)
        } else if price?.characters.count == 3 {
            attributedPriceString.appendAttributedString(greyDollarSignString)
        }
        
        return attributedPriceString
    }
}