//
//  VenueAddress+CoreDataProperties.swift
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

class VenueAddress: NSManagedObject {

    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var postalCode: String?
    @NSManaged var state: String?
    @NSManaged var street: String?
    @NSManaged var streetNumber: String?
    @NSManaged var venue: Venue?
}

extension VenueAddress {
    class func entityName() -> String {
        return "VenueAddress"
    }
    
    class func insertNewObject(moc: NSManagedObjectContext) -> VenueAddress {
        return NSEntityDescription.insertNewObjectForEntityForName(VenueAddress.entityName(), inManagedObjectContext: moc) as! VenueAddress
    }
}
