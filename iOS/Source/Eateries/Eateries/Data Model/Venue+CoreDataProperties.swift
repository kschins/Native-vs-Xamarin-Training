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
}
