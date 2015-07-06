//
//  VenueAddress.swift
//  Eateries
//
//  Created by Kasey Schindler on 7/6/15.
//  Copyright (c) 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import CoreData

class VenueAddress: NSManagedObject {

    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var postalCode: String
    @NSManaged var state: String
    @NSManaged var street: String
    @NSManaged var streetNumber: String
    @NSManaged var venue: NSSet

}
