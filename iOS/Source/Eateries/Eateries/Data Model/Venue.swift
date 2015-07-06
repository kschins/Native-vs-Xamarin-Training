//
//  Venue.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class Venue: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var telephone: String
    @NSManaged var website: String
    @NSManaged var address: VenueAddress
    @NSManaged var venueCollection: VenueCollection

}
