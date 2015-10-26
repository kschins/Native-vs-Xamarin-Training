//
//  InterfaceController.swift
//  watchEateries Extension
//
//  Created by Kasey Schindler on 10/20/15.
//  Copyright © 2015 Kasey Schindler. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var collectionsTable: WKInterfaceTable!
    var collections = [FSVenueCollection]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
            if segueIdentifier == "CollectionDetails" {
                let venueCollection = collections[rowIndex]
                
                return venueCollection
            }
            
            return nil
    }
        
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let collections = applicationContext["collections"] as? [[String : AnyObject]] {
            for collection in collections {
                // create collections and venues...
                let newCollection = FSVenueCollection(collection: collection)
                self.collections.append(newCollection)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.reloadTable()
            }
        }
    }
    
    // MARK: - Displaying Data
    
    func reloadTable() {
        if collectionsTable.numberOfRows != collections.count {
            collectionsTable.setNumberOfRows(collections.count, withRowType: "CollectionRow")
        }
        
        var index = 0
        for collection in collections {
            if let row = collectionsTable.rowControllerAtIndex(index) as? CollectionRow {
                row.collectionNameLabel.setText(collection.name)
            }
            
            index++
        }
    }
}
