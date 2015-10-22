//
//  VenueCollection+CoreDataProperties.swift
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

class VenueCollection: NSManagedObject {

    @NSManaged var canDelete: NSNumber?
    @NSManaged var creationDate: NSDate?
    @NSManaged var iconImageName: String?
    @NSManaged var name: String?
    @NSManaged var venues: NSSet?
}

extension VenueCollection {
    class func entityName() -> String {
        return "VenueCollection"
    }
    
    class func insertNewObject(moc: NSManagedObjectContext) -> VenueCollection {
        return NSEntityDescription.insertNewObjectForEntityForName(VenueCollection.entityName(), inManagedObjectContext: moc) as! VenueCollection
    }
    
    func addVenue(venue: Venue) {
        let venues = self.mutableSetValueForKey("venues")
        venues.addObject(venue)
    }
    
    func removeVenue(venue: Venue) {
        let venues = self.mutableSetValueForKey("venues")
        venues.removeObject(venue)
    }
    
    func removeAllVenues() {
        let venues = self.mutableSetValueForKey("venues")
        venues.removeAllObjects()
    }
}
