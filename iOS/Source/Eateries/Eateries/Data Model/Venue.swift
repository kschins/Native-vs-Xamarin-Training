//
//  Venue.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/7/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class Venue: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var venueID: String
    @NSManaged var telephone: String!
    @NSManaged var website: String!
    @NSManaged var twitter: String!
    @NSManaged var address: VenueAddress!
    @NSManaged var venueCollection: NSSet

    class func entityName() -> String {
        return "Venue"
    }
    
    class func insertNewObject(moc: NSManagedObjectContext) -> Venue {
        return NSEntityDescription.insertNewObjectForEntityForName(Venue.entityName(), inManagedObjectContext: moc) as! Venue
    }
}
