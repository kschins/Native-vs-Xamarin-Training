//
//  FSVenueCollection.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/23/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import Foundation

class FSVenueCollection {
    let name: String
    var venues = [FSVenue]()
    
    init(collection : [String : AnyObject]) {
        self.name = collection["name"] as! String
        
        let venuesArray = collection["venues"] as! [[String : AnyObject]]
        
        for venue in venuesArray {
            let newVenue = FSVenue()
            newVenue.venueFromDictionary(venue)
            self.venues.append(newVenue)
        }
    }
}