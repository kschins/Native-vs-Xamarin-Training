//
//  VenueCollection.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/7/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class VenueCollection: NSManagedObject {

    @NSManaged var iconImageName: String
    @NSManaged var name: String
    @NSManaged var creationDate: NSDate
    @NSManaged var canDelete: NSNumber
    @NSManaged var venues: NSSet

    class func entityName() -> String {
        return "VenueCollection"
    }
    
    class func insertNewObject(moc: NSManagedObjectContext) -> VenueCollection {
        return NSEntityDescription.insertNewObjectForEntityForName(VenueCollection.entityName(), inManagedObjectContext: moc) as! VenueCollection
    }
}

extension VenueCollection {
    func addVenue(venue: Venue) {
        let venues = self.mutableSetValueForKey("venues")
        venues.addObject(venue)
    }
    
    func removeVenue(venue: Venue) {
        let venues = self.mutableSetValueForKey("venues")
        venues.removeObject(venue)
    }
}
