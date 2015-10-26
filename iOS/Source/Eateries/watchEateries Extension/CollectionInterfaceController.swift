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
    
    var collection: FSVenueCollection!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let collection = context as? FSVenueCollection {
            self.collection = collection
            setTitle(collection.name)
        }
        
        // reload
        reloadTable()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            if segueIdentifier == "VenueDetails" {
                let venue = collection.venues[rowIndex]
 
                return venue
            }
            
            return nil
    }
    
    // MARK: - Displaying Data
    
    func reloadTable() {
        if venuesTable.numberOfRows != collection.venues.count {
            venuesTable.setNumberOfRows(collection.venues.count, withRowType: "CollectionRow")
        }
        
        var index = 0
        for venue in collection.venues {
            if let row = venuesTable.rowControllerAtIndex(index) as? CollectionRow {
                row.collectionNameLabel.setText(venue.name)
            }
            
            index++
        }
    }
}