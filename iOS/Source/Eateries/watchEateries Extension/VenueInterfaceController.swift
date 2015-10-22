//
//  VenueInterfaceController.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import WatchKit

class VenueInterfaceController: WKInterfaceController {
    var venue: Venue!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let venue = context as? Venue {
            self.venue = venue
            setTitle(venue.name)
        }
    }
}