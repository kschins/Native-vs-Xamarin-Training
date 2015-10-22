//
//  CollectionInterfaceController.swift
//  Eateries
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import Foundation
import WatchKit

class CollectionInterfaceController: WKInterfaceController {
    @IBOutlet weak var venuesTable: WKInterfaceTable!
    
    var collection: VenueCollection!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let collection = context as? VenueCollection {
            self.collection = collection
            setTitle(collection.name)
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            if segueIdentifier == "VenueDetails" {
                let venue = collection.venues?.allObjects[rowIndex]
 
                return venue
            }
            
            return nil
    }
}