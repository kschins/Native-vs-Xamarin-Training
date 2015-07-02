//
//  VenueCollection.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/1/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class VenueCollection: NSManagedObject {

    @NSManaged var iconImageName: String
    @NSManaged var name: String
    @NSManaged var venues: NSSet

}
