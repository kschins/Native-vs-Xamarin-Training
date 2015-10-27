//
//  Venue+CoreDataProperties.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/19/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

class Venue: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var telephone: String?
    @NSManaged var twitter: String?
    @NSManaged var venueID: String?
    @NSManaged var website: String?
    @NSManaged var price: String?
    @NSManaged var mainVenueCollectionName: String?
    @NSManaged var favorite: NSNumber?
    @NSManaged var address: VenueAddress?
    @NSManaged var venueCollection: NSSet?
}

extension Venue {
    class func entityName() -> String {
        return "Venue"
    }
    
    class func insertNewObject(moc: NSManagedObjectContext) -> Venue {
        return NSEntityDescription.insertNewObjectForEntityForName(Venue.entityName(), inManagedObjectContext: moc) as! Venue
    }
    
    func venueToDictionary() -> [String : AnyObject] {
        var venue: [String : AnyObject] = [
            "venueID" : venueID!,
            "name" : name!,
            "mainVenueCollectionName" : mainVenueCollectionName!,
            "favorite" : favorite!.boolValue
        ]
        
        if let twt = twitter {
            venue.updateValue(twt, forKey: "twitter")
        }
        
        if let site = website {
            venue.updateValue(site, forKey: "website")
        }
        
        if let phone = telephone {
            venue.updateValue(phone, forKey: "telephone")
        }
        
        if let money = price {
            venue.updateValue(money, forKey: "price")
        }
        
        if let street = address {
            venue.updateValue(street.venueAddressToDictionary(), forKey: "address")
        }
        
        return venue
    }
}
